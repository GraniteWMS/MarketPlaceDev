CREATE PROCEDURE [dbo].[Prescript_Picking_Qty] (
   @input dbo.ScriptInputParameters READONLY
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max) 
  )
SET NOCOUNT ON;
DECLARE @valid bit
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @DocumentNumber varchar(50)
DECLARE @DocumentID bigint
DECLARE @DocumentERPID bigint
DECLARE @CurrentERPLocation varchar(50)
DECLARE @CurrentMasterItemCode varchar(50)
DECLARE @CurrentMasterItemID bigint
DECLARE @CurrentMasterItemERPID bigint
DECLARE @ActionQtyForCurrentMasterItem decimal(19, 4)
DECLARE @RequestedQty decimal(19, 4)
DECLARE @ReservedQtyForItemInERPLocation decimal(19, 4)
DECLARE @QtyOnHandForItemInERPLocation decimal(19, 4)
DECLARE @ReservedQtyForItemOnDocument decimal(19, 4)
SELECT @DocumentNumber = Value FROM @input WHERE Name = 'Document'
SELECT @DocumentID = ID FROM Document WHERE Number = @DocumentNumber
SELECT @DocumentERPID = ERPIdentification FROM Document WHERE ID = @DocumentID
SELECT @CurrentMasterItemID = MasterItem_id FROM TrackingEntity WHERE Barcode = (SELECT Value FROM @input WHERE Name = 'TrackingEntity')
SELECT @CurrentMasterItemCode = Code FROM MasterItem WHERE ID = @CurrentMasterItemID
SELECT @CurrentMasterItemERPID = ERPIdentification FROM MasterItem WHERE ID = @CurrentMasterItemID
SELECT @ActionQtyForCurrentMasterItem = ISNULL(SUM(ISNULL(ActionQty,0)),0) FROM DocumentDetail WHERE Item_id = @CurrentMasterItemID AND Document_id = @DocumentID
SELECT TOP 1 @CurrentERPLocation = FromLocation FROM DocumentDetail WHERE Document_id = @DocumentID AND Item_id = @CurrentMasterItemID
SELECT @RequestedQty = @stepInput
SELECT @ReservedQtyForItemInERPLocation = ISNULL(QtyReserved,0)
FROM Custom_ERP_StockQtyReserved 
WHERE MasterItem_ERPIdentification = @CurrentMasterItemERPID AND [Location] = @CurrentERPLocation
SELECT @QtyOnHandForItemInERPLocation = ISNULL(Qty,0) 
FROM API_QueryStockTotals 
WHERE ERPLocation = @CurrentERPLocation AND MasterItem_id = @CurrentMasterItemID
SELECT @ReservedQtyForItemOnDocument = ISNULL(SUM(ISNULL(QtyReserved,0)) ,0)
FROM Custom_Integration_Evolution_SalesOrderDetailReserved CIESODR
INNER JOIN Document D ON CIESODR.Document_ERPIdentification = D.ERPIdentification
WHERE MasterItem_ERPIdentification = @CurrentMasterItemERPID AND 
[FromLocation] = @CurrentERPLocation AND 
D.ERPIdentification = @DocumentERPID
IF (@QtyOnHandForItemInERPLocation - @RequestedQty) >= @ReservedQtyForItemInERPLocation
BEGIN
	SELECT @valid = 1
	SELECT @message = @RequestedQty
END
ELSE
BEGIN
	IF (@ReservedQtyForItemInERPLocation - (@QtyOnHandForItemInERPLocation - @RequestedQty)) <= @ReservedQtyForItemOnDocument
	BEGIN
		SELECT @valid = 1
		SELECT @message = @RequestedQty
	END
	ELSE
	BEGIN
		SELECT @valid = 0
		SELECT @message = CONCAT('There is a reserved qty of ', @ReservedQtyForItemInERPLocation, ' for item ', @CurrentMasterItemCode, ' in location ', @CurrentERPLocation,
		'. You requested a qty of ', @RequestedQty, ', but the qty onhand is ', @QtyOnHandForItemInERPLocation, '. There is no stock reserved on this document, therefore it would overlap with the reserved qty!')
	END
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output