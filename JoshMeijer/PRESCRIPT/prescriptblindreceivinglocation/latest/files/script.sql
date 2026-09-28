CREATE PROCEDURE [dbo].[PrescriptBlindReceivingLocation] (
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
DECLARE @LocationIdentifier varchar(50)
SELECT @LocationIdentifier = @stepInput
IF EXISTS (SELECT ID FROM [Location] WHERE isActive = 1 AND (Barcode = @LocationIdentifier OR [Name] = @LocationIdentifier))
BEGIN
	SELECT @valid = 1
END
ELSE
BEGIN
	
	SELECT @valid = 0
	SELECT @message = CONCAT(@LocationIdentifier, ' is not a valid location')
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
