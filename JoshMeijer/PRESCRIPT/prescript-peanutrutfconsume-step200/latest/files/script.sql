CREATE PROCEDURE [dbo].[Prescript_PeanutRUTFConsume_Step200] (
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
@ConsumedMasterItem varchar(50),
@TrackingEntity varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'TrackingEntity'),
@Document varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Document'),
@Printer varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'PrinterName'),
@User varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'User'),
@UserID bigint,
@WastageQty decimal(19, 4) = (SELECT [Value] FROM @input WHERE [Name] = 'Comment'),
@WastageLocation varchar(50) = 'Peanut Wastage',
@Success bit,
@Batch varchar(50),
@ExpiryDate datetime,
@ConsumedBarcodeCreateDate datetime,
@Barcodes nvarchar(max)
SELECT
@ConsumedMasterItem = MI.Code,
@Batch = TE.Batch,
@ExpiryDate = TE.ExpiryDate,
@ConsumedBarcodeCreateDate = TE.CreatedDate,
@UserID = U.ID
FROM TrackingEntity TE
INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
INNER JOIN Users U ON U.[Name] = @User
WHERE TE.Barcode = @TrackingEntity
BEGIN TRY
	SET @message = 'No Wastage'
	IF @WastageQty > 0
	BEGIN
		EXECUTE [dbo].[clr_Takeon] 
		   @userName = @User
		  ,@trackingEntityIdentifier = NULL
		  ,@locationIdentifier = @WastageLocation
		  ,@masterItemIdentifier = @ConsumedMasterItem
		  ,@uom = NULL
		  ,@qty = @WastageQty
		  ,@carryingEntityIdentifier = NULL
		  ,@batch = @Batch
		  ,@serialNumber = NULL
		  ,@expiryDate = @ExpiryDate
		  ,@manufactureDate = NULL
		  ,@numberOfEntities = 1
		  ,@comment = NULL
		  ,@reference = @Document
		  ,@integrationReference = NULL
		  ,@processName = 'PEANUT_WASTAGE'
		  ,@trackingEntityOptionalFields = NULL
		  ,@success = @Success OUTPUT
		  ,@message = @message  OUTPUT
		  ,@barcodes = @Barcodes OUTPUT
		  UPDATE TrackingEntity
		  SET ExpiryDate = @ExpiryDate
		  WHERE Barcode = @Barcodes
		  EXECUTE [dbo].[clr_PrintLabel] 
		   @barcode = NULL
		  ,@barcodes = @Barcodes
		  ,@labelName = 'TrackingEntity.zpl'
		  ,@numberOfLabels = 1
		  ,@printerName = @Printer
		  ,@type = 'TRACKINGENTITY'
		  ,@userID = @UserID
		  ,@success = @success OUTPUT
		  ,@message = @message OUTPUT
		  IF @Success = 1
		  BEGIN
			SET @message = CONCAT('Wastage is ', @WastageQty, ' of ', @ConsumedMasterItem);
		  END
	  END
	SELECT 
	@valid = 1
	
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
