CREATE PROCEDURE [dbo].[Prescript_StockTakeCount_TrackingEntity] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @Barcode varchar(100)
DECLARE @MasterItem varchar(50)
DECLARE @Batch varchar(50)
DECLARE @TrackingEntityBarcode varchar(50)
DECLARE @ExpiryDate varchar(10)
DECLARE @Serial varchar(30)
DECLARE @MasterItemID bigint
DECLARE @UnitConversion decimal(19, 4)
SELECT @Barcode = rtrim(@stepInput)
IF LEN(@Barcode) > 26
BEGIN
	
	EXEC Utility_ParseSupplierBarcode 
	@Barcode, 
	@MasterItem OUTPUT, 
	@Batch OUTPUT, 
	@TrackingEntityBarcode OUTPUT, 
	@ExpiryDate OUTPUT,
	@Serial OUTPUT
	SELECT @stepInput = @TrackingEntityBarcode
END
ELSE
BEGIN
	SELECT TOP 1 @MasterItemID = MasterItem_id, @UnitConversion = Conversion from MasterItemAlias_View WHERE Code = @stepInput
	IF ISNULL(@MasterItemID, 0) <> 0
	BEGIN
		SELECT @MasterItem = Code FROM MasterItem WHERE ID = @MasterItemID
		SELECT @stepInput = @MasterItem
		INSERT INTO @Output
		SELECT 'Qty', CONVERT(VARCHAR, ISNULL(@UnitConversion, 1))
	END
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
