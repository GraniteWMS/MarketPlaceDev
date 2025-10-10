CREATE PROCEDURE [dbo].[PrescriptStocktakeTrackingEntity] (
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
DECLARE @trackingEntity varchar(30)
DECLARE @trackingEntityID int
DECLARE @session varchar(30)
DECLARE @sessionID int
DECLARE @count int

SELECT @trackingEntity = Value FROM @input WHERE Name = 'TrackingEntity'
SELECT @count = Value FROM @input WHERE Name = 'Count'
SELECT @session = Value FROM @input WHERE Name = 'Session'
SELECT @sessionID = ID FROM StockTakeSession WHERE [Name] = @session


SELECT @valid = 1

	IF EXISTS (SELECT TOP 1 ID FROM StockTakeLines WHERE StockTakeSession_id = @sessionID AND Barcode = @trackingEntity)
	BEGIN
		IF (@count = 1)
		BEGIN
			UPDATE StockTakeLines SET Count1Qty = 0 WHERE StockTakeSession_id = @sessionID AND Barcode = @trackingEntity
		END
		ELSE IF (@count = 2)
		BEGIN
			UPDATE StockTakeLines SET Count2Qty = 0 WHERE StockTakeSession_id = @sessionID AND Barcode = @trackingEntity
		END
		ELSE IF (@count = 3)
		BEGIN
			UPDATE StockTakeLines SET Count3Qty = 0 WHERE StockTakeSession_id = @sessionID AND Barcode = @trackingEntity
		END
	END



	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output

