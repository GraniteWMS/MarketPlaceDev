CREATE PROCEDURE [dbo].[PrescriptPrintCarryingEntityConfirmation] (
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


DECLARE @COUNTER INT = 1
DECLARE @Qty INT
DECLARE @BARCODEMASTERBARCODE VARCHAR(50)
DECLARE @BarcodeZeroes varchar(20) 
DECLARE @CreatedDate DateTime = GETDATE()
DECLARE @NEXTBARCODE INT

DECLARE @CarryingEntityType varchar(25)
DECLARE @Prefix varchar(10)


DECLARE @Printer varchar(50)
SELECT @Printer = VALUE FROM @input WHERE NAME = 'PrinterName'

SELECT @Qty = Value FROM @input WHERE Name = 'Qty'
SELECT @CarryingEntityType = Value FROM @input WHERE Name = 'Type'
SELECT @Prefix = Prefix FROM BarcodeMaster WHERE Name = @CarryingEntityType

SELECT @BarcodeZeroes = [Length] FROM BarcodeMaster WHERE Name = @CarryingEntityType
SELECT @NEXTBARCODE = [NextBarcode] +1 FROM BarcodeMaster WHERE Name = @CarryingEntityType

IF @Qty > (SELECT CONVERT(int, Value) FROM SystemStaticData WHERE [Key] = 'CarryingEntityPrint')
BEGIN 
	SELECT @valid = 0
	SELECT @message = 'You cannot print more than: ' + (SELECT Value FROM SystemStaticData WHERE [Key] = 'CarryingEntityPrint') + ' labels'
END
ELSE
BEGIN 
	IF @stepInput = 'Yes'
		BEGIN 

			WHILE @COUNTER <= @Qty
			BEGIN
				SELECT @NEXTBARCODE = [NextBarcode] FROM BarcodeMaster WHERE Name = @CarryingEntityType
				SELECT @BARCODEMASTERBARCODE = CONCAT(@Prefix,(REPLICATE('0',@BarcodeZeroes - LEN(@NEXTBARCODE)) + CAST(@NEXTBARCODE AS varchar)))

				INSERT INTO [dbo].[CarryingEntity]
						   ([Barcode]
						   ,[CreateDate]
						   ,[type_id]
						   ,[Status_id]
						   ,[Location_id]
						   ,[Length]
						   ,[Width]
						   ,[Height]
						   ,[Weight]
						   ,[PhysicalType]
						   ,[AuditUser]
						   ,[AuditDate])
					 VALUES
						   (@BARCODEMASTERBARCODE		
						   ,@CreatedDate	
						   ,NULL			
						   ,NULL			
						   ,NULL			
						   ,0				
						   ,0				
						   ,0				
						   ,0				
						   ,NULL			
						   ,NULL			
						   ,NULL)			

				UPDATE BarcodeMaster
				SET NextBarcode = NextBarcode + 1
				WHERE Name = @CarryingEntityType

				SELECT @COUNTER = @COUNTER + 1
			END
		END


	DECLARE @Barcodes TABLE 
	(
		ID bigint IDENTITY(1,1) NOT NULL,
		BoxBarcodes varchar(max) NOT NULL
	)

	INSERT INTO @Barcodes(BoxBarcodes)
	SELECT DISTINCT Barcode from CarryingEntity where CreateDate = @CreatedDate

	SELECT @Qty = COUNT(BoxBarcodes) FROM @Barcodes
	SELECT @COUNTER = 1

		WHILE @COUNTER <= @Qty
		BEGIN
			DECLARE @BARCODE VARCHAR(50)
				SELECT @BARCODE = BoxBarcodes FROM @Barcodes WHERE ID = @COUNTER
			DECLARE @LabelName varchar(30)
				SELECT @LabelName = @CarryingEntityType + '.zpl' 

			DECLARE @responseCode int,
					@responseJSON nvarchar(4000)

			EXEC [dbo].[CLR_PrintLabel]
				@barcode = @BARCODE,
				@Barcodes = '',
				@labelName = @LabelName,
				@NumberOfLabels = 1,
				@PrinterName = @Printer, 
				@type = 'Pallet', 
				@userID = 3,
				@responseCode = @responseCode, 
				@responseJSON = @responseJSON

			SELECT @COUNTER = @COUNTER + 1
		END
END


	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output

