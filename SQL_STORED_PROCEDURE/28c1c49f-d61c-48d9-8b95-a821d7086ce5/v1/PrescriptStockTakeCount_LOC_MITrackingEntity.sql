CREATE PROCEDURE [dbo].[PrescriptStockTakeCount_LOC_MITrackingEntity] (
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

DECLARE @LocationBarcode varchar (30)
DECLARE @Location_id bigint
DECLARE @MasterItemCode varchar (40)
DECLARE @TrackingEntityBarcode varchar (50)
DECLARE @UserName varchar (30)
DECLARE @userID bigint
DECLARE @ProcessName varchar (40)
DECLARE @NumberOfEntities int
DECLARE @Batch varchar (30)
DECLARE @ExpiryDate datetime
DECLARE @SerialNumber varchar (30)
DECLARE @Comment varchar (30)
DECLARE @Reference varchar (30)
DECLARE @PalletBarcode varchar (30)
DECLARE @assignTrackingEntityBarcode varchar (30)
DECLARE @Qty int
DECLARE @responseCode int
DECLARE @responseJSON nvarchar(4000)
DECLARE @Barcodes varchar(500)
DECLARE @StockTakeSession varchar (30)       
DECLARE @StockTakeSession_id bigint
DECLARE @MasterItem_id bigint
DECLARE @TrackingEntity_id bigint
DECLARE @NewTrackingEntity_id bigint

SELECT @LocationBarcode = Value FROM @input WHERE Name = 'Location'
SELECT @Location_id = ID FROM [Location] WHERE Barcode = @LocationBarcode
SELECT @UserName = [Value] FROM @input WHERE [Name] = 'User'
SELECT @userId = ID FROM Users WHERE [Name] = @UserName
SELECT @ProcessName = 'TAKEON'
SELECT @NumberOfEntities = 1
SELECT @Batch = NULL, @ExpiryDate = NULL, @SerialNumber = NULL, @Reference = NULL, @PalletBarcode = NULL
SELECT @Comment = 'StockTake Takeon'
SELECT @Qty = 0
SELECT @StockTakeSession = [Value] FROM @input WHERE [Name] = 'Session'
SELECT @StockTakeSession_id = ID FROM StockTakeSession WHERE [Name] = @StockTakeSession

IF EXISTS (SELECT ID FROM MasterItem WHERE Code = @stepInput AND isActive = 1)
BEGIN
	
	SELECT @MasterItemCode = @stepInput
	SELECT @MasterItem_id = ID FROM MasterItem WHERE Code = @MasterItemCode
	
	SELECT @TrackingEntityBarcode = CONCAT(@LocationBarcode, '_', @MasterItemCode)
	SELECT @assignTrackingEntityBarcode = @TrackingEntityBarcode
		
	IF EXISTS(SELECT ID FROM TrackingEntity WHERE Barcode = @TrackingEntityBarcode)
	BEGIN

		SELECT @stepInput = @TrackingEntityBarcode
		SELECT @TrackingEntity_id = ID FROM TrackingEntity WHERE Barcode = @TrackingEntityBarcode

		IF NOT EXISTS(SELECT ID FROM StockTakeLines WHERE Barcode = @TrackingEntityBarcode AND StockTakeSession_id = @StockTakeSession_id)
		BEGIN

			INSERT INTO StockTakeLines ([StockTakeSession_id], [Barcode], [MasterItemCode], [OpeningLocation_id], [OpeningQty], [Status], [MasterItem_id], [TrackingEntity_id])
			SELECT @StockTakeSession_id, @TrackingEntityBarcode, @MasterItemCode, @Location_id, 0, 'OUTSTANDING', @MasterItem_id, @TrackingEntity_id
		
		END

		SELECT @valid = 1
		SELECT @message = ''

	END
	ELSE
	BEGIN

		EXECUTE [dbo].[clr_TakeOn]
		@userID,
		@masterItemCode,
		@locationBarcode,
		@processName,
		@numberOfEntities ,
		@batch,
		@expiryDate,
		@serialNumber,
		@comment,
		@reference,
		@palletBarcode,
		@assignTrackingEntityBarcode,
		@qty,
		@responseCode OUTPUT,
		@responseJSON OUTPUT,
		@barcodes OUTPUT

		IF @responseCode = 200
		BEGIN
			
			SELECT @valid = 1
			SELECT @message = 'Barcode added to StockTake Session'

		END
		ELSE
		BEGIN
			
			SELECT @valid = 0
			SELECT @message = 'Failed to add barcode to StockTake Session'

		END

		SELECT @NewTrackingEntity_id = ID FROM TrackingEntity WHERE Barcode = @Barcodes

		INSERT INTO StockTakeLines ([StockTakeSession_id], [Barcode], [MasterItemCode], [OpeningLocation_id], [OpeningQty], [Status], [MasterItem_id], [TrackingEntity_id])
		SELECT @StockTakeSession_id, @Barcodes, @MasterItemCode, @Location_id, 0, 'OUTSTANDING', @MasterItem_id, @NewTrackingEntity_id

		SELECT @stepInput = @assignTrackingEntityBarcode

	END

END
ELSE
BEGIN

	SELECT @valid = 0
	SELECT @message = CONCAT(@stepInput, ' is not a valid item code')

END

	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput

	SELECT * FROM @Output
