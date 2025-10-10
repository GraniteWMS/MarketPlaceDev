CREATE PROCEDURE [dbo].[PrescriptReinstateTrackingEntityStep200] (
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




DECLARE @TrackingEntity varchar(50)
DECLARE @UserName varchar(50)
DECLARE @Confirm bit

SELECT @TrackingEntity = [Value] FROM @input WHERE [Name] = 'TrackingEntity'
SELECT @Confirm = [Value] FROM @input WHERE [Name] = 'Confirm'
SELECT @UserName = [Value] FROM @input WHERE [Name] = 'User'

IF @Confirm = 0
BEGIN
	SELECT @valid = 1
	SELECT @message = 'Cancelled'
END
ELSE
BEGIN
	UPDATE TrackingEntity
	SET InStock = 1
	WHERE Barcode = @TrackingEntity

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

	SELECT	@assignTrackingEntityBarcode = TrackingEntity.Barcode,
			@masterItemCode = MasterItem.Code,
			@locationBarcode = [Location].Barcode, 
			@batch = Batch, 
			@expiryDate = IIF(ExpiryDate IS NULL, NULL, CONVERT(varchar, ExpiryDate, 112)),
			@manufactureDate = IIF(ManufactureDate IS NULL, NULL, CONVERT(varchar, ManufactureDate, 112)),
			@serialNumber = SerialNumber
	FROM TrackingEntity INNER JOIN
	MasterItem ON TrackingEntity.MasterItem_id = MasterItem.ID INNER JOIN
	[Location] ON TrackingEntity.Location_id = [Location].ID
	WHERE TrackingEntity.Barcode = @TrackingEntity

	SELECT @userID = ID FROM Users WHERE [Name] = @UserName
	SELECT @processName = 'REINSTATE_TRACKINGENTITY'
	SELECT @qty = 0	
	SELECT @numberOfEntities = 1

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
		SELECT @valid = 1
		SELECT @message = 'TrackingEntity reinstated'
	END
	ELSE
	BEGIN
		UPDATE TrackingEntity
		SET InStock = 0
		WHERE Barcode = @TrackingEntity

		SELECT @valid = 0
		SELECT @message = 'Something went wrong. Please contact support'
	END
END






	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
