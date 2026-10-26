CREATE PROCEDURE [dbo].[Prescript_ReplenishToBarcode_ToTrackingEntity] (
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
@ToTrackingEntity varchar(50) = @stepInput,
@FromTrackingEntity varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'FromTrackingEntity'),
@ToTrackingEntityLocation varchar(50),
@FromTrackingEntityQty decimal(19, 4),
@FromBarcodeIsOnhold bit
SELECT
@FromERPLocation = FromLocation.ERPLocation,
@ToERPLocation = ToLocation.ERPLocation,
@ToTrackingEntityLocation = ToLocation.Barcode,
@FromTrackingEntityQty = FromTE.Qty,
@FromBarcodeIsOnhold = FromTE.OnHold
FROM TrackingEntity FromTE
INNER JOIN TrackingEntity ToTE ON ToTE.Barcode = @ToTrackingEntity
INNER JOIN [Location] FromLocation ON FromTE.Location_id = FromLocation.ID
INNER JOIN [Location] ToLocation ON ToTE.Location_id = ToLocation.ID
WHERE FromTE.Barcode = @FromTrackingEntity
BEGIN TRY
	IF @FromBarcodeIsOnhold = 1
	BEGIN
		RAISERROR('Barcode %s is on hold. You replenish from it', 16, 1, @FromTrackingEntity)
	END
	IF @FromERPLocation IS DISTINCT FROM @ToERPLocation
	BEGIN
		RAISERROR('You cannot replenish to a barcode in a different warehouse. Barcode %s is in %s and barcode %s is in %s. Transfer %s to %s first', 16, 1, @FromTrackingEntity, @FromERPLocation, @ToTrackingEntity, @ToERPLocation, @FromTrackingEntity, @ToERPLocation);
	END
	INSERT INTO @Output
	SELECT 'Location', @ToTrackingEntityLocation
	UNION ALL
	SELECT 'Qty', CONVERT(VARCHAR, @FromTrackingEntityQty)
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
