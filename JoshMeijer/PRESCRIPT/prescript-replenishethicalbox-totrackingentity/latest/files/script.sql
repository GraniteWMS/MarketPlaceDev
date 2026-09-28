CREATE PROCEDURE [dbo].[Prescript_ReplenishEthicalBox_ToTrackingEntity] (
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
DECLARE @ToCarryingEntityID bigint,
@ToCarryingEntityBarcode varchar(50) = @stepInput,
@ToCurrentBoxLocation varchar(50),
@ToBoxLocationID bigint,
@FromTrackingEntity varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'FromTrackingEntity'),
@FromTrackingEntityBatch varchar(50),
@FromTrackingEntityExpiryDate datetime,
@FromTrackingEntityMasterItemID bigint,
@ToTrackingEntity varchar(50),
@ToTrackingEntityBatch varchar(50),
@ToTrackingEntityExpiryDate datetime,
@CurrentDateTime datetime = GETDATE()
BEGIN TRY
	SELECT 
	@ToCarryingEntityID = CE.ID,
	@ToCurrentBoxLocation = L.Barcode,
	@ToBoxLocationID = L.ID
	FROM dbo.CarryingEntity CE
	INNER JOIN [Location] L ON CE.Location_id = L.ID
	WHERE CE.Barcode = @ToCarryingEntityBarcode
	IF ISNULL(@ToCarryingEntityBarcode, '') NOT LIKE 'ETHL%'
	BEGIN
		RAISERROR('Must be a Ethical (ETHL) barcode', 16, 1)
	END
	IF ISNULL(@ToCarryingEntityID, 0) = 0
	BEGIN
		RAISERROR('ETHL barcode %s does not exist', 16, 1, @stepInput)
	END
	SELECT
	@FromTrackingEntityBatch = Batch,
	@FromTrackingEntityExpiryDate = ExpiryDate,
	@FromTrackingEntityMasterItemID = MasterItem_id
	FROM TrackingEntity 
	WHERE Barcode = @FromTrackingEntity
	SELECT TOP 1
	@ToTrackingEntity = Barcode, 
	@ToTrackingEntityBatch = Batch,
	@ToTrackingEntityExpiryDate = ExpiryDate
	FROM TrackingEntity 
	WHERE BelongsToEntity_id = @ToCarryingEntityID
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
			@FromTrackingEntityBatch,
			@FromTrackingEntityExpiryDate,
			0,
			0,
			1,
			@FromTrackingEntityMasterItemID,
			@ToBoxLocationID,
			@ToCarryingEntityID,
			NULL
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT ID FROM TrackingEntity 
		WHERE 
		(BelongsToEntity_id = @ToCarryingEntityID AND InStock = 1 AND Qty > 0 AND MasterItem_id <> @FromTrackingEntityMasterItemID))
		OR
		EXISTS(SELECT ID FROM TrackingEntity 
		WHERE 
		(BelongsToEntity_id = @ToCarryingEntityID AND InStock = 1 AND Qty > 0 AND MasterItem_id = @FromTrackingEntityMasterItemID)
		AND
		(Batch IS DISTINCT FROM @FromTrackingEntityBatch OR ExpiryDate IS DISTINCT FROM @FromTrackingEntityExpiryDate))
		BEGIN
			RAISERROR('There is still stock in box %s. Scrap or pick it first, then try to receive again', 16, 1, @stepInput)
		END
		IF NOT EXISTS (
		SELECT ID
		FROM TrackingEntity
		WHERE BelongsToEntity_id = @ToCarryingEntityID
		  AND InStock = 1
		  AND Qty >= 0
		  AND MasterItem_id = @FromTrackingEntityMasterItemID
		  AND Batch IS NOT DISTINCT FROM @FromTrackingEntityBatch
		  AND ExpiryDate IS NOT DISTINCT FROM @FromTrackingEntityExpiryDate
		)
		BEGIN
			UPDATE dbo.TrackingEntity
			SET BelongsToEntity_id = NULL
			WHERE BelongsToEntity_id = @ToCarryingEntityID AND Qty = 0
		END
		
	END
	SET @stepInput = @ToTrackingEntity;
	INSERT INTO @Output
	SELECT 'Location', @ToCurrentBoxLocation
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
