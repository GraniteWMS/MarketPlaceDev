CREATE PROCEDURE [dbo].[PrescriptTakeonManufactureLocation] (
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
DECLARE @MasterItemCode varchar(50)
DECLARE @Printer varchar(50)
SELECT @Printer = RTRIM(UPPER(Value)) FROM @input WHERE Name = 'PrinterName'
DECLARE @ProductionLine varchar(20) = @stepInput
DECLARE @ProductionLine_id bigint
DECLARE @ProductionLineNumber varchar(1) = RIGHT(@ProductionLine,1)
DECLARE @Batch varchar(10) 
DECLARE @LoadPalletCount int
DECLARE @BottlesPerPallet int
DECLARE @PalletsPerBatch int
DECLARE @CurrentJob varchar(30)
IF ISNULL(@Printer,'') <> '' OR @Printer IN ('L1','L2','L3','L4','L5','L6')
BEGIN
	IF EXISTS(SELECT ID FROM [Location] WHERE [Type] = 'PRODUCTION' AND Barcode = @ProductionLine)
	BEGIN
		
		
		SELECT @ProductionLine_id = ID FROM [Location] WHERE Barcode = @ProductionLine
		SELECT TOP 1 @Batch = CurrentBatch , @PalletsPerBatch  = PalletsPerBatch, @BottlesPerPallet = BottlesPerPallet, @CurrentJob = CurrentJob ,@MasterItemCode = MasterItem
		FROM Custom_ProductionLineAssignments 
		WHERE ProductionLine = @ProductionLine AND isActive = 1
		ORDER by ID DESC
		IF (SELECT COUNT(TX.ID) FROM [Transaction] TX INNER JOIN TrackingEntity TE ON TX.TrackingEntity_id = TE.ID
		WHERE Process  IN ('TAKEONMANUFACTURE','TAKEON-MANTEST')
		AND ToLocation_id = @ProductionLine_id AND TE.Batch = @Batch and DATEDIFF(DAY,TX.Date,getdate()) < 2) >= @PalletsPerBatch
		BEGIN
			
			SELECT @Batch = SUBSTRING(@Batch,1,5) + CONVERT(varchar(3),CONVERT(int,SUBSTRING(@Batch,6,LEN(@Batch-5))) + 1)
			UPDATE Custom_ProductionLineAssignments SET CurrentBatch = @Batch
			WHERE ProductionLine = @ProductionLine AND isActive = 1
		END
		INSERT INTO @Output
		SELECT 'SerialNumber', @CurrentJob
		INSERT INTO @Output
		SELECT 'MasterItem', @MasterItemCode
		INSERT INTO @Output
		SELECT 'Batch', @Batch
		INSERT INTO @Output
		SELECT 'Reference', @CurrentJob
		INSERT INTO @Output
		SELECT 'Qty', CONVERT(varchar(10),@BottlesPerPallet)
		SELECT @valid = 1
		SELECT @message = ''
	END
	ELSE
	BEGIN
		SELECT @valid = 0
		SELECT @message = CONCAT(UPPER(@ProductionLine),' is not a valid Production Line Location.')
	END
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = 'Printer not chosen or incorrect. Please log in with a valid printer.'
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
