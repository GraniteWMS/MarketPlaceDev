CREATE PROCEDURE [dbo].[PrescriptReplenishPickfaceLocation] (
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




IF EXISTS(SELECT ID FROM [Location] WHERE Barcode = @stepInput AND [Type] = 'PICKFACE' AND isActive = 1)
BEGIN
	SELECT @valid = 1
END
ELSE IF EXISTS(SELECT ID FROM [Location] WHERE [Name] = @stepInput AND [Type] = 'PICKFACE' AND isActive = 1)
BEGIN
	SELECT @valid = 1
	SELECT @stepInput = Barcode FROM [Location] WHERE [Name] = @stepInput
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = CONCAT(@stepInput, ' is not a valid pickface location')
END





	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
