CREATE PROCEDURE [dbo].[PrescriptOrderCheckingLocation] (
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




IF EXISTS(SELECT * FROM [Location] WHERE Barcode = @stepInput OR [Name] = @stepInput)
BEGIN
	SELECT @valid = 1
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = CONCAT('Location ', @stepInput, ' not found')
END





	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
