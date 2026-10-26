CREATE PROCEDURE [dbo].[Utility_GetSortOrder]
    @DocumentNumber varchar(50)
AS 
    SET NOCOUNT ON;
    DECLARE @DOCNUMBER varchar(30)
    DECLARE @DOCTYPE varchar(30)
    DECLARE @ORDERNUMBER varchar(30)
    DECLARE @TRADINGPARTNERCODE varchar(20)
    DECLARE @TRADINGPARTNERDESC varchar(60)
	DECLARE @ID bigint
	DECLARE @OUTSTANDINGQTY decimal(19,4)
	DECLARE @TEQTY decimal(19,4)
	DECLARE @ITEMCODE  varchar(25)
	DECLARE @ITEMDESCRIPTION  varchar(100)
	DECLARE @QTYALOCATTED decimal(19,4)
	DECLARE @ReturnTable TABLE 
	(
		DocumentNumber varchar(30),
		DocumentType varchar(30),
		OrderNumber varchar(30),
		TradingPartnerCode  varchar(20),
		TradingPartnerDescription varchar(60),
		Code varchar(25), 
		Description varchar (100), 
		Barcode varchar(30), 
		Qty  decimal(19,4), 
		OutstandingQty  decimal(19,4), 
		SerialNumber  varchar(30), 
		CreatedDate DateTime, 
		Batch  varchar(50), 
		ExpiryDate  DateTime, 
		Site  varchar(30), 
		ERPLocation varchar(15), 
		Location varchar(30),
		LocationType varchar(30),
		SortOrder int
	)
	
    SET @QTYALOCATTED = 0;
    
    DECLARE header CURSOR FOR
	SELECT PickSlip.Number, 
	       PickSlip.[Type], 
	       CASE WHEN OrderHeader.Number IS NULL THEN PickSlip.Number ELSE OrderHeader.Number END as OrderNumber,
		   CASE WHEN PickSlip.TradingPartnerCode IS NULL THEN OrderHeader.TradingPartnerCode ELSE PickSlip.TradingPartnerCode END AS TradingPartnerCode, 
	       CASE WHEN PickSlip.TradingPartnerDescription IS NULL THEN OrderHeader.TradingPartnerDescription ELSE PickSlip.TradingPartnerDescription END AS TradingPartnerDescription, 
		   MasterItem.Code, 
		   PickSlipDetail.Qty, 
		   MasterItem.Description
		   
	FROM dbo.[Document] AS PickSlip 
	INNER JOIN dbo.[DocumentDetail] AS PickSlipDetail ON PickSlip.ID = PickSlipDetail.Document_id 
	INNER JOIN dbo.[MasterItem] as MasterItem ON MasterItem.ID = PickSlipDetail.Item_id  
	LEFT JOIN dbo.[DocumentDetail] AS OrderDetail ON OrderDetail.ID = PickSlipDetail.LinkedDetail_id 
	LEFT JOIN dbo.[Document] as OrderHeader ON OrderDetail.Document_id = OrderHeader.ID 
    WHERE (PickSlipDetail.Completed = 0) 
	   OR (PickSlipDetail.Completed IS NULL)
	GROUP BY PickSlip.Number, PickSlip.[Type], MasterItem.Code, MasterItem.Description, MasterItem.UOM, PickSlipDetail.Comment, PickSlipDetail.Qty, 
			 PickSlipDetail.ActionQty, PickSlipDetail.FromLocation, PickSlip.TradingPartnerCode, PickSlip.TradingPartnerDescription, 
			 OrderHeader.Number, OrderHeader.TradingPartnerCode, OrderHeader.TradingPartnerDescription
	HAVING ((SUM(PickSlipDetail.Qty) - SUM(ISNULL(PickSlipDetail.ActionQty, 0))) > 0 AND PickSlip.Number = @DocumentNumber)
	OPEN header;
	FETCH NEXT FROM header 
	INTO @DOCNUMBER, @DOCTYPE, @ORDERNUMBER, @TRADINGPARTNERCODE, @TRADINGPARTNERDESC, @ITEMCODE, @OUTSTANDINGQTY, @ITEMDESCRIPTION;
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		DECLARE detail CURSOR FOR
		SELECT     dbo.TrackingEntity.ID, dbo.TrackingEntity.Qty
		FROM         dbo.Location INNER JOIN
							  dbo.TrackingEntity ON dbo.Location.ID = dbo.TrackingEntity.Location_id INNER JOIN
							  dbo.MasterItem ON dbo.TrackingEntity.MasterItem_id = dbo.MasterItem.ID
		WHERE     (dbo.TrackingEntity.InStock = 1) AND ((dbo.TrackingEntity.OnHold = 0) OR (dbo.TrackingEntity.OnHold IS NULL)) AND ( dbo.MasterItem.Code = @ITEMCODE) AND (dbo.TrackingEntity.Qty > 0)
		OPEN detail;
		
		FETCH NEXT FROM detail 
		INTO @ID,@TEQTY;
		
		IF @@FETCH_STATUS <> 0 
			BEGIN
				INSERT INTO @ReturnTable (DocumentNumber, DocumentType, OrderNumber, TradingPartnerCode, TradingPartnerDescription, Code, Description, OutstandingQty) 
					values(@DOCNUMBER, @DOCTYPE, @ORDERNUMBER, @TRADINGPARTNERCODE, @TRADINGPARTNERDESC, @ITEMCODE, @ITEMDESCRIPTION, @OUTSTANDINGQTY)
			END
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			IF (@QTYALOCATTED < @OUTSTANDINGQTY) 
			BEGIN
					SET @QTYALOCATTED  = (@QTYALOCATTED + @TEQTY) 
				
					INSERT INTO @ReturnTable (DocumentNumber, DocumentType, OrderNumber, TradingPartnerCode, TradingPartnerDescription, Code, Description, Barcode, Qty, SerialNumber, CreatedDate, Batch, ExpiryDate, 
					Site, ERPLocation, Location, OutstandingQty, LocationType, SortOrder) 
					SELECT @DOCNUMBER, @DOCTYPE, @ORDERNUMBER, @TRADINGPARTNERCODE, @TRADINGPARTNERDESC, dbo.MasterItem.Code, dbo.MasterItem.Description, dbo.TrackingEntity.Barcode, 
					       dbo.TrackingEntity.Qty, dbo.TrackingEntity.SerialNumber, dbo.TrackingEntity.CreatedDate, dbo.TrackingEntity.Batch, dbo.TrackingEntity.ExpiryDate, 
						   dbo.Location.Site, dbo.Location.ERPLocation, dbo.Location.Name AS Location, @OUTSTANDINGQTY, Location.Type, ISNULL(Custom_PickslipUOMSortOrder.SortOrder, 99)
					FROM dbo.Location INNER JOIN
					dbo.TrackingEntity ON dbo.Location.ID = dbo.TrackingEntity.Location_id INNER JOIN
					dbo.MasterItem ON dbo.TrackingEntity.MasterItem_id = dbo.MasterItem.ID LEFT JOIN
					Custom_PickslipUOMSortOrder ON MasterItem.UOM = Custom_PickslipUOMSortOrder.UOM
					WHERE (dbo.TrackingEntity.id = @ID)
				
			END
		
		FETCH NEXT FROM detail 
		INTO @ID,@TEQTY;
		END 
		
		
		SET @QTYALOCATTED = 0;
		CLOSE detail;
		DEALLOCATE detail;
		
		FETCH NEXT FROM header 
		INTO @DOCNUMBER, @DOCTYPE, @ORDERNUMBER, @TRADINGPARTNERCODE, @TRADINGPARTNERDESC, @ITEMCODE, @OUTSTANDINGQTY, @ITEMDESCRIPTION;
	END
	CLOSE header;
	DEALLOCATE header;
	
SELECT 
Code, 
ROW_NUMBER() OVER (ORDER BY SortOrder, [Location])
FROM @ReturnTable
ORDER BY SortOrder, [Location]
