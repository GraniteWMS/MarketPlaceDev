CREATE PROCEDURE [dbo].[PrescriptTakeonManPalletConfirmPallet] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit =1
DECLARE @message varchar(MAX) 
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @MasterItemCode varchar(50)
DECLARE @MasterItemID BIGINT
DECLARE @Printer varchar(50)
SELECT @Printer = RTRIM(UPPER(Value)) FROM @input WHERE Name = 'PrinterName'
DECLARE @ProductionLine varchar(20) = (SELECT [Value] FROM @input WHERE Name = 'Location')
DECLARE @ProductionLine_id bigint
DECLARE @ProductionLineNumber varchar(1) = RIGHT(@ProductionLine,1)
DECLARE @CarryingEntity varchar(20) = (SELECT [Value] FROM @input WHERE Name = 'CarryingEntity')
DECLARE @CE_ID BIGINT = (SELECT ID FROM CarryingEntity WHERE Barcode = @CarryingEntity)
DECLARE @Batch varchar(10) 
DECLARE @LoadPalletCount int
DECLARE @BottlesPerPallet int
DECLARE @PalletsPerBatch int
DECLARE @QtyPerPack int
DECLARE @CurrentJob varchar(30)
BEGIN TRY
	IF ISNULL(@Printer,'') = '' OR @Printer NOT IN ('L1','L2','L3','L4','L5','L6')
			RAISERROR('Printer not chosen or incorrect. Please log in with a valid printer.',16,1)
	IF (SELECT Status_id FROM CarryingEntity WHERE ID = @CE_ID) = 11		
		RAISERROR('This pallet %s is FULL - Click Back and NEW for a new pallet',16,1,@CarryingEntity)
	IF NOT EXISTS(SELECT ID FROM [Location] WHERE [Type] = 'PRODUCTION' AND Barcode = @ProductionLine)
			RAISERROR('%s is not a valid Production Line Location.',16,1,@ProductionLine)
		
		
		SELECT @ProductionLine_id = ID FROM Location WHERE Barcode = @ProductionLine
		SELECT TOP 1 @Batch = CurrentBatch , @PalletsPerBatch  = PalletsPerBatch, @BottlesPerPallet = BottlesPerPallet, @CurrentJob = CurrentJob , @MasterItemCode = MasterItem
		FROM Custom_ProductionLineAssignments 
		WHERE ProductionLine = @ProductionLine AND isActive = 1
		ORDER by ID DESC
		SELECT @MasterItemID = ID FROM MasterItem WHERE Code = @MasterItemCode
		SELECT @QtyPerPack = [Value] FROM OptionalFieldValues_MasterItem 
		WHERE OptionalField_id = (SELECT ID FROM OptionalFields 
									WHERE AppliesTo = 'MASTERITEM' AND [Name] = 'QtyPerPack')
		AND BelongsTo_id = @MasterItemID
		
		IF ISNULL(@QtyPerPack,0) =0
			RAISERROR('The Qty Per Pack is not set for this item',16,1)
		INSERT INTO @Output
		SELECT 'SerialNumber', @CurrentJob
		INSERT INTO @Output
		SELECT 'MasterItem', @MasterItemCode
		INSERT INTO @Output
		SELECT 'Batch', @Batch
		INSERT INTO @Output
		SELECT 'Reference', @CurrentJob
		INSERT INTO @Output
		SELECT 'Qty', CONVERT(varchar(10),@QtyPerPack)
		SELECT @valid = 1
		SELECT @message = ''
	
END TRY
BEGIN CATCH
	SELECT @Valid = 0, @message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
