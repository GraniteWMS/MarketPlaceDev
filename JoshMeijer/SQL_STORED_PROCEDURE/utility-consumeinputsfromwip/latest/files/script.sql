
CREATE Procedure [dbo].[Utility_ConsumeInputsfromWIP]
	@MasterItem varchar(50),
	@Site varchar(50),
	@Location varchar(50),
	@Pallet varchar(50),
	@dQtyMade Decimal(19,4),
	@UserName varchar(50),
	@Success bit OUTPUT
AS
BEGIN
	DECLARE @Debug bit = 0
	DECLARE @Counter bigint
	DECLARE @Min bigint
	DECLARE @Max bigint
	
	DECLARE @TrackingEntityQty Decimal(19,4)
	DECLARE @ConsumeMasterItem varchar(50)
	DECLARE @message varchar(max)
	DECLARE @trackingEntityIdentifier varchar(max),
		   @adjustmentQty Decimal(19,4),
		   @comment varchar(max) = @Pallet,
		   @reference varchar(max) = @Pallet,
		   @adjustmentType varchar(max) = 'QtyDecrease',
		   @integrationReference varchar(max),
		   @processName varchar(50) = 'ADJUSTMENT',
		   @trackingEntityOptionalFields varchar(max)
	
	DECLARE @RMLinesonBOM TABLE
	(
	ID bigint identity(1, 1),
	MasterItem varchar(50),
	QtyToConsume Decimal(19,4),
	Unit varchar(50),
	[Status] varchar(max),
	QtyConsumed Decimal(19,4)
	)
	BEGIN TRY
	
		SELECT @Success = 1	
		
		INSERT INTO @RMLinesonBOM (MasterItem, QtyToConsume,[Unit],[Status])
		select  COMPONENT,QTY * @dQtyMade,[UNIT],'ENTERED'
		FROM Integration_Accpac_BomD
		WHERE ITEMNO =@MasterItem AND [BOMNO] = 1
		ORDER BY [LINENO]
		
		SELECT @Min = MIN(ID), @Max = MAX(ID), @Counter = MIN(ID) FROM @RMLinesonBOM
		WHILE @Counter >= @Min AND @Counter <= @Max
		BEGIN
			SELECT @ConsumeMasterItem = MasterItem, @adjustmentQty = QtyToConsume - isnull(QtyConsumed,0) FROM @RMLinesonBOM WHERE ID = @Counter
		  
		    SELECT TOP 1 @trackingEntityIdentifier = TrackingEntity.Barcode,
			@TrackingEntityQty = Qty
			FROM TrackingEntity 
			INNER JOIN Location ON TrackingEntity.Location_id = Location.ID
			INNER JOIN MasterItem ON TrackingEntity.MasterItem_id = MasterItem.ID
			WHERE Location.Site = @site
			AND Location.Barcode = @Location
			AND MasterItem.Code = @ConsumeMasterItem
			AND TrackingEntity.Qty >0
			AND InStock = 1
			AND OnHold = 0
			AND StockTake  = 0
			ORDER by trackingentity.ID Desc
			
			IF @Debug = 1 SELECT 'Item',@ConsumeMasterItem
			IF @Debug = 1 SELECT 'Qty',@adjustmentQty,'On TE:',@trackingEntityIdentifier
			
			IF @TrackingEntityQty < @adjustmentQty 
				SELECT @adjustmentQty = @TrackingEntityQty
			INSERT INTO custom_LogMessages (Message,Date)
			SELECT CONCAT('Consume for MI:',@ConsumeMasterITem, ' TE:', ISNULL(@trackingEntityIdentifier,'NONE'), ' Location:',@Location, ' Qty to adjust:',@adjustmentQty,'Raw material Consumption log'), getdate()
			IF @trackingEntityIdentifier is not null
			  
			   EXEC [dbo].clr_Adjustment
			   @UserName,
			   @trackingEntityIdentifier,
			   @adjustmentQty,
			   @comment,
			   @reference,
			   @adjustmentType,
			   @integrationReference,
			   @processName,
			   @trackingEntityOptionalFields,
			   @success OUTPUT,
			   @message OUTPUT
			ELSE
				SELECT @Success = 1
	
			IF @Debug = 1 SELECT @Success
			IF @Debug = 1 SELECT @message
		    IF @success = 1
			BEGIN
				UPDATE @RMLinesonBOM SET QtyConsumed = @adjustmentQty 
				WHERE ID = @Counter
				UPDATE @RMLinesonBOM SET [Status] = 'COMPLETE' 
				WHERE ID = @Counter and QtyToConsume = QtyConsumed
				If (SELECT [Status] FROM @RMLinesonBOM WHERE ID = @Counter) = 'COMPLETE'
					SET @Counter = @Counter + 1  
			END
			ELSE
			BEGIN
				UPDATE @RMLinesonBOM SET [Status] = 'ERROR' + @message
				WHERE ID = @Counter
				SET @Counter = @Counter + 1 
			END
		END
	END TRY
	BEGIN CATCH
		SELECT @Success = 0
		INSERT INTO custom_LogMessages (Message,Date)
		SELECT CONCAT('Consume Error on MI:', @MasterItem, ERROR_MESSAGE()), getdate()
	END CATCH
END
