CREATE PROCEDURE [dbo].[PrescriptPickingPostDocument_PostServiceItems] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @Qty Decimal(6,0),
		@MasterItem_ID bigint, 
		@MasterItemCode varchar(30),
		@Document varchar(30),
		@Document_ID bigint,
		@LineNumber varchar(10)
SELECT @Document = Value FROM @input WHERE Name = 'DOCUMENT'
SELECT @Document_ID = (SELECT ID FROM Document WHERE Number = @Document)
DECLARE cursor_product CURSOR FOR 
SELECT Qty, Item_id, LineNumber 
FROM DocumentDetail
WHERE Document_ID = @Document_ID AND Completed <> 1 
OPEN cursor_product
FETCH NEXT FROM cursor_product INTO @Qty, @MasterItem_ID, @LineNumber
WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @MasterItemCode = (SELECT Code FROM MasterItem WHERE ID = @MasterItem_ID)
	IF @MasterItemCode IN ('659083A', 'COURSE', 'LABOUR', 'POSTAGES', 'SPARE PART', 'WEB DISCOUNT')
	BEGIN
		UPDATE DocumentDetail
		SET ActionQty = @Qty, Completed = 1 
		WHERE LineNumber = @LineNumber AND Document_ID = @Document_ID 
	
		INSERT INTO [Transaction] (Date, [FromQty], ToQty, ActionQty, UOM, UOMConversion, DocumentReference, Comment, IntegrationStatus, IntegrationReady, TrackingEntity_id, FromLocation_id, ToLocation_id, User_id, Document_id, DocumentLine_id, [Type], Process)
		SELECT getdate(),0,0,DD.Qty,DD.UOM,DD.UOMConversion,'','Trigger-AUTOPICK SERVICE ITEM',0,1,TrackingEntity.ID,TrackingEntity.Location_id
		,(SELECT TOP 1 ID FROM Location WHERE Barcode = 'PACKING')  
		,(SELECT TOP 1 ID FROM Users WHERE Name = '0'),@Document_ID,DD.ID,'PICK','PICKINGPOST'
		FROM DocumentDetail DD INNER JOIN
		MasterItem ON DD.Item_id = MasterItem.ID INNER JOIN 
		TrackingEntity ON TrackingEntity.Barcode = MasterItem.Code
		WHERE        (DD.Document_id = @Document_ID) AND LineNumber = @LineNumber 
	END
		
	FETCH NEXT FROM cursor_product INTO	@Qty, @MasterItem_ID, @LineNumber
END
CLOSE cursor_product
DEALLOCATE cursor_product
IF NOT EXISTS(SELECT * FROM DocumentDetail WHERE Completed = 0 AND Document_id = @Document_ID)
BEGIN
	UPDATE Document SET Status = 'COMPLETE'
	WHERE ID = @Document_ID
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
