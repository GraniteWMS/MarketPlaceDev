CREATE PROCEDURE  [dbo].[Prescript_Picking_Document] (
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
DECLARE @success bit
DECLARE @DocumentNumber varchar(50) = (SELECT Number FROM Document WHERE [Description] = @stepInput OR Number = @stepInput)
DECLARE @Document_id bigint = (SELECT ID FROM Document WHERE Number = @DocumentNumber)
DECLARE @DocumentStatus varchar(30)
BEGIN TRY
	IF @DocumentNumber IS NULL
		RAISERROR('ERROR: Document %s not found.',16, 1, @stepInput)
	SELECT @stepInput = @DocumentNumber
	SELECT @DocumentStatus = [Status] FROM Document WHERE Number = @stepInput
	IF @DocumentStatus NOT IN('ENTERED', 'RELEASED')
		RAISERROR('ERROR: Document is not in Status ENTERED or RELEASED.', 16, 1)
	
	EXEC Utility_Document_PickSequence
	@DocumentNumber = @stepInput
	,@success = @success OUTPUT
    ,@Message = @message OUTPUT
	IF @Success = 0
		RAISERROR(@message, 16, 1)
	SELECT @valid = 1
	,@message = @message
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