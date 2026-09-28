CREATE PROCEDURE [dbo].[Prescript_UnreceiveTransaction_Confirmation] (
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
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput'; 
BEGIN TRY
	IF ISNULL(@stepInput, '') <> 'YES'
	BEGIN
		RAISERROR('Please go back a step', 16, 1);
	END
	SELECT 
	@valid = 1,
	@message = @stepInput;
END TRY
BEGIN CATCH
	SELECT 
	@valid = 0,
	@message = ERROR_MESSAGE();
END CATCH
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
