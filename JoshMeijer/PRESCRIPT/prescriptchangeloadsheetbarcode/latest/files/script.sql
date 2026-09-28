CREATE PROCEDURE [dbo].[PrescriptChangeLoadSheetBarcode] (
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
DECLARE @User varchar(25)
DECLARE @Printer varchar(10)
DECLARE @LoadNumber varchar(50)
DECLARE @Document varchar(20)
DECLARE @MasterItem varchar(50)
DECLARE @Counter int
DECLARE @PreviousTransactionID bigint
DECLARE @LatestTransactionID bigint
DECLARE @LoadTruck varchar(50)
DECLARE @userID bigint
DECLARE @masterItemCode nvarchar(50)
DECLARE @locationBarcode nvarchar(50)
DECLARE @processName nvarchar(50)
DECLARE @numberOfEntities bigint
DECLARE @batch nvarchar(50)
DECLARE @expiryDate datetime
DECLARE @manufactureDate datetime
DECLARE @serialNumber nvarchar(50)
DECLARE @comment nvarchar(50)
DECLARE @reference nvarchar(50)
DECLARE @palletBarcode nvarchar(50)
DECLARE @assignTrackingEntityBarcode nvarchar(50)
DECLARE @qty numeric(19,4)
DECLARE @responseCode int
DECLARE @responseJSON nvarchar(max)
DECLARE @barcodes nvarchar(max)
DECLARE @barcode nvarchar(50)
DECLARE @labelName nvarchar(500)
DECLARE @numberOfLabels int
DECLARE @printerName nvarchar(50)
DECLARE @type nvarchar(50)
DECLARE @responseCodePrint int
DECLARE @responseJSONPrint nvarchar(max)
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput'
SELECT @LoadNumber = Value FROM @input WHERE Name = 'LoadNumber'
SELECT @LoadTruck = Value FROM @input WHERE Name = 'LoadTruck'
SELECT @User = Value FROM @input WHERE Name = 'User'
SELECT @Printer = Value FROM @input WHERE Name = 'printerName'
SELECT @masterItemCode = MI.Code
FROM MasterItem MI
INNER JOIN TrackingEntity TE ON TE.MasterItem_id = MI.ID
WHERE TE.Barcode = @stepInput 
IF ISNULL(@masterItemCode,'') != '' AND @stepInput NOT LIKE 'T%'
BEGIN
	SELECT TOP 1 @PreviousTransactionID = TR.ID
	FROM [Transaction] TR
	INNER JOIN TrackingEntity TE ON TE.ID = TR.TrackingEntity_id
								AND TR.[Type] = 'TAKEON'
								AND TR.Process = 'LOADPREP'
								AND TR.ReversalTransaction_id = 0
	WHERE TE.Barcode = @stepInput
	ORDER BY Date DESC
	SET @assignTrackingEntityBarcode = @stepInput
	SET @userID = (SELECT ID FROM Users WHERE [Name] = @User)
	SET @locationBarcode = 'DIS'
	SET @processName = 'LOADPREP'
	SET @numberOfEntities = 1
	SET @reference = @LoadNumber
	SET @palletBarcode = @LoadNumber
	SET @qty = 1
	SET @responseCode = 200
	SET @barcode = NULL
	SET @labelName = 'DeliveryParcelQR.zpl'
	SET @numberOfLabels = 1
	SET @printerName = @Printer
	SET @type = 'TRACKINGENTITY'
	UPDATE TrackingEntity
	SET InStock = 1,
		Qty = 0,
		SerialNumber = '',
		Batch = ''
	WHERE Barcode = @assignTrackingEntityBarcode
	EXECUTE [dbo].[clr_TakeOn] 
		@userID
		,@masterItemCode
		,@locationBarcode
		,@processName
		,@numberOfEntities
		,@batch
		,@expiryDate
		,@manufactureDate
		,@serialNumber
		,@comment
		,@reference
		,@palletBarcode
		,@assignTrackingEntityBarcode
		,@qty
		,@responseCode OUTPUT
		,@responseJSON OUTPUT
		,@barcodes OUTPUT
	IF @responseCode = 200
	BEGIN
		EXECUTE [dbo].[clr_PrintLabel] 
			@barcode
			,@barcodes
			,@labelName
			,@numberOfLabels
			,@printerName
			,@type
			,@userID
			,@responseCodePrint OUTPUT
			,@responseJSONPrint OUTPUT
		UPDATE TrackingEntity
		SET InStock = 0,
			SerialNumber = @LoadNumber,
			Batch = @LoadTruck
		WHERE Barcode = @assignTrackingEntityBarcode
		SELECT TOP 1 @LatestTransactionID = TR.ID
		FROM [Transaction] TR
		INNER JOIN TrackingEntity TE ON TE.ID = TR.TrackingEntity_id
									AND TR.[Type] = 'TAKEON'
									AND TR.Process = 'LOADPREP'
									AND TR.ReversalTransaction_id = 0
		WHERE TE.Barcode = @stepInput
		ORDER BY Date DESC
		UPDATE [Transaction]
		SET ReversalTransaction_id = @LatestTransactionID
		WHERE ID = @PreviousTransactionID
	END
	
	SELECT @Counter = @Counter + 1
	IF @responseCode = 200
	BEGIN
		SELECT @valid = 1
		SELECT @message = 'Tracking Entities moved to selected load sheet.'
	END
	ELSE
	BEGIN
		SELECT @valid = 0
		SELECT @message = CONCAT('Failed to create one or more Tracking Entites. ',@responseJSON)
	END
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = concat(@stepInput,' is not a valid Loading Barcode')
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
