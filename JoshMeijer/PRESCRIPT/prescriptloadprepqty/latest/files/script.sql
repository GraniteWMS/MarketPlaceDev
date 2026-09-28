CREATE PROCEDURE [dbo].[PrescriptLoadPrepQty] (
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
DECLARE @InputQty int
DECLARE @LastTESuffix int
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
SELECT @Document = Value FROM @input WHERE Name = 'Document'
SELECT @MasterItem = Value FROM @input WHERE Name = 'MasterItem'
SELECT @User = Value FROM @input WHERE Name = 'User'
SELECT @Printer = Value FROM @input WHERE Name = 'printerName'
SELECT TOP 1 @LastTESuffix = ISNULL(CONVERT(int,SUBSTRING(TE.Barcode,CHARINDEX('-',TE.Barcode,1)+1,3)),0)
FROM TrackingEntity TE
WHERE TE.Barcode LIKE CONCAT(@Document,'-%')
ORDER BY CONVERT(int,SUBSTRING(TE.Barcode,CHARINDEX('-',TE.Barcode,1)+1,3)) DESC
SELECT @Counter = 1
SELECT @InputQty = @stepInput
SET @userID = (SELECT ID FROM Users WHERE [Name] = @User)
SET @masterItemCode = @MasterItem
SET @locationBarcode = 'DIS'
SET @processName = 'LOADPREP'
SET @numberOfEntities = 1
SET @reference = @LoadNumber
SET @serialNumber = @LoadNumber
SET @batch = @LoadTruck
SET @qty = 1
SET @responseCode = 200
SET @barcode = NULL
SET @labelName = 'DeliveryParcelQR.zpl'
SET @numberOfLabels = 1
SET @printerName = @Printer
SET @type = 'TRACKINGENTITY'
IF @InputQty < 10
BEGIN
	WHILE @Counter <= @InputQty AND @responseCode = 200
	BEGIN
		SET @assignTrackingEntityBarcode = CONCAT(@Document,'-',@Counter + ISNULL(@LastTESuffix,0))
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
			SET InStock = 0
			WHERE Barcode = @assignTrackingEntityBarcode
		END
	
		SELECT @Counter = @Counter + 1
	END
	IF @responseCode = 200
	BEGIN
		SELECT @valid = 1
		SELECT @message = 'Tracking Entities created.'
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
	SELECT @message = 'Qty cannot be greater than 9.'
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
