CREATE PROCEDURE [dbo].[Prescript_Replenish_FromTrackingEntity] (
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
DECLARE @FromLocationType varchar(50) 
SELECT @FromLocationType = L.[Type]
FROM TrackingEntity TE 
INNER JOIN [Location] L ON TE.Location_id = L.ID
WHERE TE.Barcode = @stepInput
BEGIN TRY
	IF ISNULL(@FromLocationType, '') <> 'BULK'
	BEGIN
		RAISERROR('Barcode location must be of type BULK', 16, 1)
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
