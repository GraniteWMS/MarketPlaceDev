CREATE PROCEDURE [dbo].[PrescriptBlindReceivingCarryingEntity] (
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
SELECT @stepInput = UPPER(@stepInput)
DECLARE @CarryingEntityBarcode varchar (50)
SELECT @CarryingEntityBarcode = @stepInput
IF @CarryingEntityBarcode = 'NEW'
BEGIN
	
	DECLARE @UserName varchar(30)
	SELECT @UserName = [Value] FROM @input WHERE [Name] = 'User'
	SELECT @CarryingEntityBarcode = CONCAT(Prefix, LEFT('000000', ([Length] - LEN(NextBarcode))), NextBarcode + 1) FROM BarcodeMaster WHERE [Name] = 'PALLET'
	UPDATE BarcodeMaster SET NextBarcode = (NextBarcode + 1 ) WHERE [Name] = 'PALLET'
	INSERT INTO CarryingEntity (Barcode, CreateDate, AuditDate, AuditUser)
	SELECT @CarryingEntityBarcode, GETDATE(), GETDATE(), @UserName
	SELECT @stepInput = @CarryingEntityBarcode
	DECLARE @barcode varchar(50)
	DECLARE @barcodes varchar(4000)
	DECLARE @labelName varchar(500)
	DECLARE @numberOfLabels int
	DECLARE @printerName varchar(50)
	DECLARE @type varchar(50)
	DECLARE @userID bigint
	DECLARE @responseCode int
	DECLARE @responseJSON varchar(max)
	SELECT @barcode = @CarryingEntityBarcode
	SELECT @labelName = 'Pallet.zpl'
	SELECT @numberOfLabels = 1
	SELECT @printerName = [Value] FROM @input WHERE [Name] = 'PrinterName'
	SELECT @type = 'Pallet'
	SELECT @userID = ID FROM Users WHERE [Name] = @UserName
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
	IF @responseCode = 200
	BEGIN
		SELECT @message = CONCAT('Pallet ', @CarryingEntityBarcode, ' created')
	END
	ELSE
	BEGIN
		SELECT @message = CONCAT('Pallet ', @CarryingEntityBarcode, ' created but failed to print - use the Reprint Label process')
	END
	SELECT @valid = 1
END
ELSE IF EXISTS(SELECT ID FROM CarryingEntity WHERE Barcode = @stepInput)
BEGIN
	SELECT @valid = 1
END
ELSE IF @stepInput = ''
BEGIN
	SELECT @valid = 1
	SELECT @message = ('No CarryingEntity Barcode selected')
END
ELSE 
BEGIN
	SELECT @valid = 0
	SELECT @message = CONCAT('CarryingEntity with barcode ''', @stepInput, ''' does not exist')
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
