CREATE PROCEDURE [dbo].[PrescriptSpotCheckConfirm] (
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
DECLARE @Cage varchar(100)
	SELECT @Cage = Value from @input WHERE Name = 'Cage'
DECLARE @Session varchar(100)
	SELECT @Session = Value FROM @input WHERE Name = 'Session'
DECLARE @Barcode varchar(100)
	SELECT @Barcode = Value FROM @input WHERE Name = 'Barcode'
DECLARE @StockTakeSessionId bigint
BEGIN TRY
	IF(UPPER(@stepInput) = 'YES')
	BEGIN
	
		SELECT @StockTakeSessionId = ID FROM StockTakeSession WHERE Name = @Session
	
		INSERT INTO StockTakeLines (StockTakeSession_id, Barcode, MasterItemCode, OpeningLocationERP, OpeningQty, Status, OpeningLocation_id, MasterItem_id, TrackingEntity_id)
		SELECT @StockTakeSessionId, TrackingEntity.Barcode, MasterItem.Code, Location.ERPLocation, TrackingEntity.Qty, 'OUTSTANDING', Location.ID, MasterItem_id, TrackingEntity.ID
		FROM	TrackingEntity  
				INNER JOIN Location ON TrackingEntity.Location_id = Location.ID
				INNER JOIN MasterItem On TrackingEntity.MasterItem_id = MasterItem.ID
		WHERE	(MasterItem.Code = @Barcode OR Location.Barcode = @Barcode OR Location.Name = @Barcode OR TrackingEntity.Barcode = @Barcode)
				AND InStock = 1
				AND Location.Category = @Cage
				AND NOT EXISTS (SELECT 1 from StockTakeLines where StockTakeSession_id = @StockTakeSessionId and Barcode = TrackingEntity.Barcode)
		SELECT @valid = 1
	END
END TRY
BEGIN CATCH
	SELECT @message = ERROR_MESSAGE()
	SELECT @valid = 0
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
