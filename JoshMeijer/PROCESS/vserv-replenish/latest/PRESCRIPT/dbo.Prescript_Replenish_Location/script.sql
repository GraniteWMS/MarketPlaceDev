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
DECLARE @FromTrackingEntity varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'FromTrackingEntity')
,@ToLocationType varchar(50) 
,@ToLocationID bigint
,@ExpiryDate datetime
,@MasterItemID bigint
,@ToTrackingEntity varchar(50)
,@CurrentDateTime datetime = GETDATE()
SELECT 
@ToLocationID = L.ID, 
@ToLocationType = L.[Type]
FROM [Location] L
WHERE L.Barcode = @stepInput
SELECT
@ExpiryDate = ExpiryDate,
@MasterItemID = MasterItem_id
FROM TrackingEntity
WHERE Barcode = @FromTrackingEntity
BEGIN TRY
	IF ISNULL(@ToLocationType, '') <> 'PICKFACE'
	BEGIN
		RAISERROR('Location must be of type PICKFACE', 16, 1)
	END
	SELECT @ToTrackingEntity = Barcode
	FROM TrackingEntity
	WHERE 
	Location_id = @ToLocationID
	AND MasterItem_id = @MasterItemID
	AND ExpiryDate IS NOT DISTINCT FROM @ExpiryDate
	IF ISNULL(@ToTrackingEntity, '') = ''
	BEGIN
		UPDATE BarcodeMaster
		SET NextBarcode += 1
		WHERE [Name] = 'TRACKINGENTITY'
		SELECT @ToTrackingEntity = CONCAT([Prefix], REPLICATE('0', [Length] - LEN([NextBarcode])), [NextBarcode])
		FROM BarcodeMaster WHERE [Name] = 'TRACKINGENTITY'
		INSERT INTO [dbo].[TrackingEntity]
			   ([Barcode]
			   ,[Qty]
			   ,[SerialNumber]
			   ,[CreatedDate]
			   ,[Value]
			   ,[Batch]
			   ,[ExpiryDate]
			   ,[OnHold]
			   ,[StockTake]
			   ,[InStock]
			   ,[MasterItem_id]
			   ,[Location_id]
			   ,[BelongsToEntity_id]
			   ,[ManufactureDate])
			SELECT 
			@ToTrackingEntity,
			0,
			NULL,
			@CurrentDateTime,
			NULL,
			NULL,
			@ExpiryDate,
			0,
			0,
			1,
			@MasterItemID,
			@ToLocationID,
			NULL,
			NULL
	END
	INSERT INTO @Output
	SELECT 'ToTrackingEntity', @ToTrackingEntity
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
