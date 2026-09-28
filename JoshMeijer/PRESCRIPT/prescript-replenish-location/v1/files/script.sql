CREATE PROCEDURE [dbo].[Prescript_Replenish_Location] (
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
@FromERPLocation varchar(50),
@ToERPLocation varchar(50),
@ToLocation varchar(50) = @stepInput,
@FromTrackingEntity varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'FromTrackingEntity'),
@FromBarcodeIsOnhold bit
SELECT
@FromERPLocation = FromLocation.ERPLocation,
@FromBarcodeIsOnhold = FromTE.OnHold,
@ToERPLocation = ToLocation.ERPLocation
FROM TrackingEntity FromTE
INNER JOIN [Location] FromLocation ON FromTE.Location_id = FromLocation.ID
INNER JOIN [Location] ToLocation ON ToLocation.Barcode = @stepInput
WHERE FromTE.Barcode = @FromTrackingEntity
BEGIN TRY
	IF @FromBarcodeIsOnhold = 1
	BEGIN
		RAISERROR('Barcode %s is on hold. You replenish from it', 16, 1, @FromTrackingEntity)
	END
	IF @FromERPLocation IS DISTINCT FROM @ToERPLocation
	BEGIN
		RAISERROR('You cannot replenish to a barcode in a different warehouse. Barcode %s is in %s and location %s is in %s. Transfer to %s first', 16, 1, @FromTrackingEntity, @FromERPLocation, @ToLocation, @ToERPLocation, @FromTrackingEntity, @ToERPLocation);
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
