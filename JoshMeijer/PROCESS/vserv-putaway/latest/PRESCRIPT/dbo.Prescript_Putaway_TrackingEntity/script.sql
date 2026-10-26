CREATE PROCEDURE [dbo].[Prescript_Putaway_TrackingEntity] (
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
BEGIN TRY
	IF EXISTS(SELECT ID FROM TrackingEntity WHERE Barcode = @stepInput)
	BEGIN
		SELECT @FromLocationType = L.[Type]
		FROM TrackingEntity TE 
		INNER JOIN [Location] L ON TE.Location_id = L.ID
		WHERE TE.Barcode = @stepInput
	END
	ELSE IF EXISTS(SELECT ID FROM CarryingEntity WHERE Barcode = @stepInput)
	BEGIN
		SELECT @FromLocationType = L.[Type]
		FROM CarryingEntity CE 
		INNER JOIN [Location] L ON CE.Location_id = L.ID
		WHERE CE.Barcode = @stepInput
	END
	IF ISNULL(@FromLocationType, '') <> 'RECEIVING'
	BEGIN
		RAISERROR('Barcode location must be of type RECEIVING', 16, 1)
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
