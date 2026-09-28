CREATE PROCEDURE [dbo].[PrescriptStocktakeCustomPallet] (
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
IF EXISTS (SELECT 1 
			FROM CarryingEntity
			WHERE Barcode = @stepInput)
BEGIN
	SELECT @valid = 1
	SELECT @message = ''
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = CONCAT(@stepInput, ' is not a valid pallet number')
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output