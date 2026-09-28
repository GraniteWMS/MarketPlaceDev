CREATE PROCEDURE [dbo].[Prescript_TakeonEthical_Location] (
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
@LocationType varchar(50)
BEGIN TRY
	SELECT 
	@LocationType = [Type]
	FROM dbo.[Location]
	WHERE Barcode = @stepInput
	IF ISNULL(@LocationType, '') NOT LIKE 'ETHL%'
	BEGIN
		RAISERROR('Location %s must be an Ethical location', 16, 1, @stepInput)
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
