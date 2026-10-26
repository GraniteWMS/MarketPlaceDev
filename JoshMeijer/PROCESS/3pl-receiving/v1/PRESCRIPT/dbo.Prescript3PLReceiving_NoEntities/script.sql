CREATE PROCEDURE [dbo].[Prescript3PLReceiving_NoEntities] (
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
IF ISNUMERIC(@stepInput) = 0 or CONVERT(int,@stepInput) > 21
BEGIN
	SELECT @valid = 0
	SELECT @message = 'Please Enter a Number.  It should not be more than 21'
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
