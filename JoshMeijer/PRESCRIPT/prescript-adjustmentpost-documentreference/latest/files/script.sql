CREATE PROCEDURE [dbo].[Prescript_AdjustmentPost_DocumentReference] (
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
DECLARE @transactionID nvarchar(max)
DECLARE @document nvarchar(max)
DECLARE @documentReference nvarchar(max) = @stepInput
DECLARE @documents nvarchar(max)
DECLARE @reference nvarchar(max)
DECLARE @transactionType nvarchar(max)
DECLARE @processName nvarchar(max) = 'ADJUSTMENTPOST'
DECLARE @success bit
BEGIN TRY
	EXECUTE [dbo].[clr_IntegrationPost] 
   @transactionID
  ,@document
  ,@documentReference
  ,@documents
  ,@reference
  ,@transactionType
  ,@processName
  ,@success OUTPUT
  ,@message OUTPUT
	IF @success = 0
	BEGIN
		RAISERROR(@message, 16, 1);
	END
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
