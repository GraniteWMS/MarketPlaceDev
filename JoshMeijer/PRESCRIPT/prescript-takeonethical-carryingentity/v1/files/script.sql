CREATE PROCEDURE [dbo].[Prescript_TakeonEthical_CarryingEntity] (
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
DECLARE @CarryingEntityID bigint,
@CarryingEntityBarcode varchar(50) = @stepInput,
@CurrentDateTime datetime = GETDATE(),
@CurrentUser varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'User'),
@MasterItem varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'MasterItem'),
@LocationtBoxShouldBeInID bigint = (SELECT ID FROM [Location] WHERE Barcode = (SELECT [Value] FROM @input WHERE [Name] = 'Location')),
@MasterItemID bigint,
@ExpiryDate date = (SELECT CONVERT(DATE, [Value]) FROM @input WHERE [Name] = 'ExpiryDate'),
@Batch varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Batch'),
@UserID bigint,
@Printer varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'PrinterName')
SELECT @MasterItemID = ID FROM MasterItem WHERE Code = @MasterItem
SELECT @UserID = ID FROM Users WHERE [Name] = @CurrentUser
BEGIN TRY
	IF ISNULL(@stepInput, '') = 'PRINT ITEM CODE LABEL'
	BEGIN
		EXECUTE [dbo].[clr_PrintLabel] 
	   @barcode = @MasterItem
	  ,@barcodes = NULL
	  ,@labelName = 'MasterItem.zpl'
	  ,@numberOfLabels = 1
	  ,@printerName = @Printer
	  ,@type = 'MASTERITEM'
	  ,@userID = @UserID
	  ,@success = @valid OUTPUT
	  ,@message = @message OUTPUT
		RAISERROR('Item code label for %s printed', 16, 1, @MasterItem)
	END
	IF ISNULL(@stepInput, '') = 'NEW BOX'
	BEGIN
		SELECT @CarryingEntityBarcode = CONCAT([Prefix], REPLICATE('0', [Length] - LEN(NextBarcode)), NextBarcode)
		FROM BarcodeMaster
		WHERE [Name] = 'ETHICALBOX'
		INSERT INTO dbo.CarryingEntity(Barcode, CreateDate, Location_id, AuditDate, AuditUser)
		SELECT @CarryingEntityBarcode, @CurrentDateTime, @LocationtBoxShouldBeInID, @CurrentDateTime, @CurrentUser
		
		UPDATE BarcodeMaster
		SET NextBarcode += 1
		WHERE [Name] = 'ETHICALBOX'
		EXECUTE [dbo].[clr_PrintLabel] 
	   @barcode = @CarryingEntityBarcode
	  ,@barcodes = NULL
	  ,@labelName = 'EthicalBox.zpl'
	  ,@numberOfLabels = 1
	  ,@printerName = @Printer
	  ,@type = 'PALLET'
	  ,@userID = @UserID
	  ,@success = @valid OUTPUT
	  ,@message = @message OUTPUT
		SET @stepInput = @CarryingEntityBarcode
	END
	SELECT 
	@CarryingEntityID = CE.ID
	FROM dbo.CarryingEntity CE
	INNER JOIN [Location] L ON CE.Location_id = L.ID
	WHERE CE.Barcode = @CarryingEntityBarcode
	IF ISNULL(@CarryingEntityBarcode, '') NOT LIKE 'ETHL%'
	BEGIN
		RAISERROR('Must be a Ethical (ETHL) barcode', 16, 1)
	END
	IF ISNULL(@CarryingEntityID, 0) = 0
	BEGIN
		RAISERROR('ETHL barcode %s does not exist', 16, 1, @stepInput)
	END
	IF EXISTS(SELECT ID FROM TrackingEntity 
	WHERE 
	(BelongsToEntity_id = @CarryingEntityID AND InStock = 1 AND Qty > 0 AND MasterItem_id <> @MasterItemID))
	OR
	EXISTS(SELECT ID FROM TrackingEntity 
	WHERE 
	(BelongsToEntity_id = @CarryingEntityID AND InStock = 1 AND Qty > 0 AND Location_id <> @LocationtBoxShouldBeInID))
	OR
	EXISTS(SELECT ID FROM TrackingEntity 
	WHERE 
	(BelongsToEntity_id = @CarryingEntityID AND InStock = 1 AND Qty > 0 AND MasterItem_id = @MasterItemID)
	AND
	(Batch IS DISTINCT FROM @Batch OR ExpiryDate IS DISTINCT FROM @ExpiryDate))
	BEGIN
		RAISERROR('There is still stock in box %s. Scrap or pick it first, then try to receive again', 16, 1, @stepInput)
	END
	UPDATE dbo.TrackingEntity
	SET BelongsToEntity_id = NULL
	WHERE BelongsToEntity_id = @CarryingEntityID AND Qty = 0
	UPDATE CarryingEntity
	SET Location_id = @LocationtBoxShouldBeInID
	WHERE ID = @CarryingEntityID AND Location_id <> @LocationtBoxShouldBeInID
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
