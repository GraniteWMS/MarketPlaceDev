CREATE PROCEDURE [dbo].[PrescriptAddLocationsToStockTake] (
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

DECLARE @Session varchar(30) = @stepInput
DECLARE @NewSession varchar(30)

IF(NOT EXISTS(SELECT * FROM StockTakeSession WHERE Name = @Session AND Active = 1) AND @Session <> 'New Session')
	BEGIN
		SELECT @valid = 1, @message = CONCAT(@Session, ' is not valid.')
	END
ELSE IF EXISTS(SELECT * FROM StockTakeSession WHERE Name = @Session AND Active = 1)
	BEGIN 
		SELECT @valid = 1
	END
ELSE IF (@Session = 'New Session')
	BEGIN 
		UPDATE BarcodeMaster
		SET NextBarcode = NextBarcode + 1
		WHERE Name = 'STOCKTAKESESSION'

		SELECT @NewSession = CONCAT(Prefix, RIGHT('000000000' + CONVERT(varchar(30),NextBarcode), Length)) 
		FROM BarcodeMaster
		WHERE Name = 'STOCKTAKESESSION'

		INSERT INTO StockTakeSession (Name, CreateDate, Active)
		SELECT @NewSession, GETDATE(), 1

		SELECT @valid = 1, @message = @NewSession + ' created.'

		SET @stepInput = @NewSession
	END

INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput


SELECT * FROM @Output
