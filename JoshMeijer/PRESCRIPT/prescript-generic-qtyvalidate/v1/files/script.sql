CREATE PROCEDURE [dbo].[Prescript_Generic_QtyValidate] (
   @input dbo.ScriptInputParameters READONLY
)
AS
DECLARE @Output TABLE(
  Name varchar(max),
  Value varchar(max)
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput'
BEGIN TRY
	EXEC Utility_CheckQtyLimit
	@Qty = @stepInput
	,@valid = @valid OUTPUT
	,@message = @message OUTPUT
	IF @valid = 0
		RAISERROR(@message, 16, 1)
END TRY
BEGIN CATCH
	SELECT @valid = 0
	,@message = ERROR_MESSAGE()
END CATCH
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
