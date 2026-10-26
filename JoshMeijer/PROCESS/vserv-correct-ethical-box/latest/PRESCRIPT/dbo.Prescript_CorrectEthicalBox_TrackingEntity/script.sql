CREATE PROCEDURE [dbo].[Prescript_CorrectEthicalBox_TrackingEntity] (
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
SELECT @stepInput = UPPER(Value) FROM @input WHERE Name = 'StepInput' 
DECLARE @TrackingEntity varchar(50)
BEGIN TRY
	IF ISNULL(@stepInput, '') NOT LIKE 'ETHL%'
	BEGIN
		RAISERROR('Must be a Ethical (ETHL) barcode', 16, 1)
	END
	SELECT
	@TrackingEntity = TE.Barcode
	FROM TrackingEntity TE
	INNER JOIN CarryingEntity CE ON TE.BelongsToEntity_id = CE.ID
	WHERE CE.Barcode = @stepInput
	AND TE.Instock = 1
	IF ISNULL(@TrackingEntity, '') = ''
	BEGIN
		RAISERROR('No stock linked to %s', 16, 1, @stepInput)
	END
	SET @stepInput = @TrackingEntity;
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
