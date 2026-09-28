CREATE PROCEDURE [dbo].[Prescript_Receiving_NoBoxes] (
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
	SELECT @valid = 1
	SELECT @message = @stepInput
IF ISNUMERIC(@stepInput) = 0
BEGIN
	SELECT @valid = 0
	SELECT @message = 'Please Enter a Number'
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
