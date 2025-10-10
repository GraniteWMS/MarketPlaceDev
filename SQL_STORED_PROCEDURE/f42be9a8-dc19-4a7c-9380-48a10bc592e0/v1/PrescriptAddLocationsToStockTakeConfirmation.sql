CREATE PROCEDURE [dbo].[PrescriptAddLocationsToStockTakeConfirmation] (
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

DECLARE @Session varchar(30) 
	SELECT @Session = Value FROM @input WHERE Name = 'Session'
DECLARE @SessionId bigint
	SELECT @SessionId = ID FROM StockTakeSession WHERE Name = @Session
DECLARE @Location varchar(30) 
	SELECT @Location = Value FROM @input WHERE Name = 'Location'
DECLARE @LocationID bigint 
	SELECT @LocationID = ID FROM Location WHERE Name = @Location OR Barcode = @Location

IF (@stepInput = 'Yes')
BEGIN
	IF (ISNULL(@LocationID, 0) = 0)
		BEGIN
			SELECT @valid = 0, @message = CONCAT(@stepInput, ' is not a valid location')
		END
	ELSE IF EXISTS (SELECT * FROM StockTakeLines WHERE OpeningLocation_id = @LocationID AND StockTakeSession_id = @SessionId)
		BEGIN
			SELECT @valid = 0, @message = CONCAT(@stepInput, ' is already in the session.')
		END
	ELSE 
		BEGIN
			
			INSERT INTO StockTakeLines (StockTakeSession_id, Barcode, MasterItemCode, OpeningLocationERP ,OpeningLocation_id, OpeningQty, Status, MasterItem_id, TrackingEntity_id)
			SELECT @SessionId, TrackingEntity.Barcode, MasterItem.Code, Location.ERPLocation, Location.ID, TrackingEntity.Qty, 'OUTSTANDING', MasterItem.ID, TrackingEntity.ID
			FROM	TrackingEntity
					INNER JOIN Location ON TrackingEntity.Location_id = Location.ID 
					INNER JOIN MasterItem ON TrackingEntity.MasterItem_id = MasterItem.ID
			WHERE	Location.ID = @LocationID 
					AND TrackingEntity.InStock = 1

			SELECT @valid = 1, @message = CONCAT(@Location, ' added to session')
		END
END

INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput


SELECT * FROM @Output
