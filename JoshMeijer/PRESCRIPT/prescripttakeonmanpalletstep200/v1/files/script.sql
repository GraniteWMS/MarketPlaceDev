CREATE PROCEDURE [dbo].[PrescriptTakeonManPalletStep200] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit 
DECLARE @message varchar(MAX)  = ''
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @User varchar(50) = (SELECT [Value] FROM @input WHERE Name = 'User')
DECLARE @userID bigint
SELECT @userID = ID FROM Users WHERe Name = @User
DECLARE @MasterItemCode varchar(50)
DECLARE @MasterItemID BIGINT
DECLARE @Printer varchar(50)
SELECT @Printer = RTRIM(UPPER(Value)) FROM @input WHERE Name = 'PrinterName'
DECLARE @ProductionLine varchar(20) = (SELECT [Value] FROM @input WHERE Name = 'Location')
DECLARE @CarryingEntity varchar(20) = (SELECT [Value] FROM @input WHERE Name = 'CarryingEntity')
DECLARE @CE_ID BIGINT = (SELECT ID FROM CarryingEntity WHERE Barcode = @CarryingEntity)
DECLARE @ProductionLine_id bigint
DECLARE @ProductionLineNumber varchar(1) = RIGHT(@ProductionLine,1)
DECLARE @Batch varchar(10) 
DECLARE @CurrentPalletPackCount int
DECLARE @BottlesPerPallet int
DECLARE @QtyPerPack int
DECLARE @PalletsPerBatch int
DECLARE @CurrentJob varchar(30)
BEGIN TRY
	IF ISNULL(@Printer,'') <> '' OR @Printer IN ('L1','L2','L3','L4','L5','L6')
	BEGIN
		
		
		SELECT @ProductionLine_id = ID FROM Location WHERE Barcode = @ProductionLine
		SELECT TOP 1 @Batch = CurrentBatch , @PalletsPerBatch  = PalletsPerBatch, @BottlesPerPallet = BottlesPerPallet, @CurrentJob = CurrentJob ,@MasterItemCode = MasterItem
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
		IF (SELECT COUNT(TX.ID) FROM [Transaction] TX INNER JOIN TrackingEntity TE ON TX.TrackingEntity_id = TE.ID
		WHERE Process  IN ('TAKEONMANUFACTURE','TAKEON-MANTEST')
		AND ToLocation_id = @ProductionLine_id AND TE.Batch = @Batch and DATEDIFF(DAY,TX.Date,getdate()) < 2) >= @PalletsPerBatch
		BEGIN
			SELECT @Batch = SUBSTRING(@Batch,1,5) + CONVERT(varchar(3),CONVERT(int,SUBSTRING(@Batch,6,LEN(@Batch-5))) + 1)
			UPDATE Custom_ProductionLineAssignments SET CurrentBatch = @Batch
			WHERE ProductionLine = @ProductionLine AND isActive = 1
		END
		
		SELECT @CurrentPalletPackCount = COUNT(*) FROM TrackingEntity 
		WHERE BelongsToEntity_id = @CE_ID
		AND InStock = 1 and Qty > 0 
		SELECT  @BottlesPerPallet = [Value] FROM OptionalFieldValues_MasterItem 
		WHERE OptionalField_id = (SELECT ID FROM OptionalFields 
									WHERE AppliesTo = 'MASTERITEM' AND [Name] = 'QtyOnPallet') 
		AND BelongsTo_id = @MasterItemID
		SELECT  @QtyPerPack = [Value] FROM OptionalFieldValues_MasterItem 
		WHERE OptionalField_id = (SELECT ID FROM OptionalFields 
									WHERE AppliesTo = 'MASTERITEM' AND [Name] = 'QTYPERPACK') 
		AND BelongsTo_id = @MasterItemID
		
		SELECT @message = 'Current Pallet Pack Count:' + Convert(char(10),@CurrentPalletPackCount) +  '  -Bottles per Pallet:' + convert(char(10),@BottlesPerPallet) + ' -Qty per Pack:' + Convert(char(10),@QtyPerPack)
		IF @CurrentPalletPackCount >= @BottlesPerPallet/@QtyPerPack 
		BEGIN
			
		
			UPDATE CarryingEntity SET PhysicalType ='FULLPALLET' , Status_id = 11 
			WHERE ID = @CE_ID
				
			DECLARE @barcode nvarchar(50) = @CarryingEntity
			DECLARE @barcodes nvarchar(4000) = NULL
			DECLARE @labelName nvarchar(500) = 'Pallet.zpl'
			DECLARE @numberOfLabels int = 1
			DECLARE @printerName nvarchar(50) = @Printer
			DECLARE @type nvarchar(50) = 'CarryingEntity'
			
			DECLARE @responseCode int
			DECLARE @responseJSON nvarchar(max)
			EXECUTE [dbo].[clr_PrintLabel] 
			   @barcode
			  ,@barcodes
			  ,@labelName
			  ,@numberOfLabels
			  ,@printerName
			  ,@type
			  ,@userID
			  ,@responseCode OUTPUT
			  ,@responseJSON OUTPUT
			IF @responseCode <> 200
				SELECT @message = @responseJSON
						
		END
			
		SELECT @valid = 1
	
	END
	ELSE
		RAISERROR('Printer not chosen or incorrect. Please log in with a valid printer.',16,1)
END TRY
BEGIN CATCH
	SELECT @valid = 0, @message = ERROR_MESSAGE()
END CATCH
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
