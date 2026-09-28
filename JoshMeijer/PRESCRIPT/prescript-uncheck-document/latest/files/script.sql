CREATE PROCEDURE [dbo].[Prescript_Unpack_Document] (
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
SET @valid = 1
SET @message = @stepInput
IF NOT EXISTS(SELECT ID FROM Document WHERE Number = @stepInput AND [Type] = 'ORDER')
BEGIN
	SET @valid = 0
	SET @message = CONCAT(@stepInput, ' does not exist')
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
