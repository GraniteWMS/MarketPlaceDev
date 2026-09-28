CREATE PROCEDURE [dbo].[Prescript_UnpickTransaction_TransactionID] (
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
DECLARE @Document varchar(50) = (SELECT Value FROM @input WHERE Name = 'Document')
BEGIN TRY
	IF NOT EXISTS(SELECT * FROM WebTemplate_UnpickTransaction_TransactionID WHERE DocumentNumber = @Document AND TransactionID = ISNULL(TRY_CONVERT(BIGINT, @stepInput), 0))
		RAISERROR('Transaction not found on document %s', 16, 1, @Document)
	SELECT 
	@valid = 1,
	@message = @stepInput
END TRY
BEGIN CATCH
	SELECT 
	@valid = 0,
	@message = ERROR_MESSAGE()
END CATCH
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
