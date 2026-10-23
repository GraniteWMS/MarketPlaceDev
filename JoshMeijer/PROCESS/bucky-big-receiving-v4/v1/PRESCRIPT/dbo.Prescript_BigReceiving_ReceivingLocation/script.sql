CREATE PROCEDURE [dbo].[Prescript_BigReceiving_ReceivingLocation] (
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
DECLARE @LinkReference varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Document')
DECLARE @DocumentERPLocation varchar(50) = (SELECT TOP 1 ERPLocation FROM Document WHERE RouteName = @LinkReference)
BEGIN TRY
	IF NOT EXISTS(SELECT ID FROM [Location] WHERE Barcode = @stepInput AND ERPLocation = @DocumentERPLocation) 
	BEGIN
		RAISERROR(N'There is not location %s linked to ERP Location %s', 16, 1, @stepInput, @DocumentERPLocation)
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
