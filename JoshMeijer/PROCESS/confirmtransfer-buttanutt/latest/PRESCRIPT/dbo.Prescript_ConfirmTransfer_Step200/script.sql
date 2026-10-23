CREATE PROCEDURE [dbo].[Prescript_ConfirmTransfer_Step200] (
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
DECLARE
@UserID bigint = (SELECT ID FROM Users WHERE [Name] = (SELECT [Value] FROM @input WHERE [Name] = 'User')),
@DocumentID bigint = (SELECT ID FROM Document WHERE Number = (SELECT [Value] FROM @input WHERE [Name] = 'Document')),
@TrackingEntity varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'MasterItem')
BEGIN TRY
	IF ISNULL(@TrackingEntity, '') = ''
	BEGIN
		RAISERROR('Could not determine last barcode confirmed on this document', 16, 1);
	END
	UPDATE TrackingEntity
	SET OnHold = 0
	WHERE Barcode = @TrackingEntity
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
