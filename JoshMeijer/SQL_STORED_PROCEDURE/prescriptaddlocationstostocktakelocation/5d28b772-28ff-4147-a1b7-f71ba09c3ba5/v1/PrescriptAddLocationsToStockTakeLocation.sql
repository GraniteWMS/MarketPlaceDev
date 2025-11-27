CREATE PROCEDURE [dbo].[PrescriptAddLocationsToStockTakeLocation] (
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
DECLARE @LocationID bigint 
	SELECT @LocationID = ID FROM Location WHERE Name = @stepInput OR Barcode = @stepInput

IF (ISNULL(@LocationID, 0) = 0)
	BEGIN
		SELECT @valid = 0, @message = CONCAT(@stepInput, ' is not a valid location')
	END
ELSE IF EXISTS (SELECT * FROM StockTakeLines WHERE OpeningLocation_id = @LocationID AND StockTakeSession_id = @SessionId)
	BEGIN
		SELECT @valid = 0, @message = CONCAT(@stepInput, ' is already in the session.')
	END
ELSE 
	SELECT @valid = 1


INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput


SELECT * FROM @Output
