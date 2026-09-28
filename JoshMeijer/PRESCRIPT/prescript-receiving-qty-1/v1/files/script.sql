CREATE PROCEDURE [dbo].[Prescript_Receiving_Qty] (
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
DECLARE @NumberOfBoxes bigint
SELECT @NumberOfBoxes = Value FROM @input WHERE Name = 'Comment'
	SELECT @valid = 1
	SELECT @message = @stepInput
IF ISNUMERIC(@stepInput) = 0
BEGIN
	SELECT @valid = 0
	SELECT @message = 'Please enter a number'
END
ELSE
BEGIN
	SET @stepInput = @stepInput * @NumberOfBoxes
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
