CREATE PROCEDURE [dbo].[Prescript_PeanutConsume_Step200] (
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
@ConsumedQty decimal(19, 4) = (SELECT [Value] FROM @input WHERE [Name] = 'Qty'),
@Document varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Document'),
@TrackingEntity varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'TrackingEntity'),
@User varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'User'),
@WastagePercentage decimal(19, 4),
@WastageQty decimal(19, 4),
@WastageLocation varchar(50) = 'Peanut Wastage',
@Success bit,
@Batch varchar(50),
@ExpiryDate datetime,
@ConsumedBarcodeCreateDate datetime,
@Barcodes nvarchar(max)
SELECT
@ConsumedMasterItem = MI.Code,
@WastagePercentage = ISNULL(CONVERT(DECIMAL(19, 4), DD.Comment), 0),
@Batch = TE.Batch,
@ExpiryDate = TE.ExpiryDate,
@ConsumedBarcodeCreateDate = TE.CreatedDate
FROM TrackingEntity TE
INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
INNER JOIN Document D ON D.Number = @Document
INNER JOIN DocumentDetail DD ON DD.Document_id = D.ID AND DD.Item_id = MI.ID
WHERE TE.Barcode = @TrackingEntity
BEGIN TRY
	SET @message = 'No wastage'
	SET @WastageQty = @ConsumedQty * (@WastagePercentage / 100)
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
		  ,@success = @Success OUTPUT
		  ,@message = @message  OUTPUT
		  ,@barcodes = @Barcodes OUTPUT
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
