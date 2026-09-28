CREATE PROCEDURE [dbo].[Prescript_ReceivingEthicalLoose_CarryingEntity] (
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
DECLARE @CarryingEntity varchar(50)
,@User varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'User')
,@CurrentDateTime datetime = GETDATE()
,@LocationID bigint = (SELECT ID FROM dbo.[Location] WHERE Barcode = 'ETHICAL RECEIVING')
,@PrinterName varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'PrinterName')
,@success bit
DECLARE
@UserID bigint = (SELECT ID FROM Users WHERE [Name] = @User)
BEGIN TRY
	IF @stepInput = 'NEW BOX'
	BEGIN
		SELECT @CarryingEntity = CONCAT([Prefix], REPLICATE('0', [Length] - LEN([NextBarcode])), [NextBarcode])
		FROM dbo.BarcodeMaster
		WHERE [Name] = 'BOX'
		UPDATE dbo.BarcodeMaster
		SET NextBarcode += 1
		WHERE [Name] = 'BOX'
		INSERT INTO dbo.CarryingEntity(Barcode, CreateDate, Location_id, AuditUser, AuditDate, PhysicalType)
		SELECT @CarryingEntity, @CurrentDateTime, @LocationID, @User, @CurrentDateTime, 'ETHL_REC'
		SET @stepInput = @CarryingEntity
		EXECUTE [dbo].[clr_PrintLabel] 
	   @barcode = @stepInput
	  ,@barcodes = NULL
	  ,@labelName = 'EthicalReceivingBox.zpl'
	  ,@numberOfLabels = 1
	  ,@printerName = @PrinterName
	  ,@type = 'BOX'
	  ,@userID = @UserID
	  ,@success = @success OUTPUT
	  ,@message = @message OUTPUT
	END
	ELSE
	BEGIN
		IF ISNULL(@stepInput, '') <> '' AND ISNULL(@stepInput, '') NOT LIKE 'BOX%'
		BEGIN
			RAISERROR('Must be an ethical receiving box barcode', 16, 1)
		END
		IF ISNULL(@stepInput, '') <> '' AND NOT EXISTS(SELECT ID FROM dbo.CarryingEntity WHERE Barcode = @stepInput AND PhysicalType = 'ETHL_REC')
		BEGIN
			RAISERROR('Ethical receiving box barcode %s does not exist', 16, 1, @stepInput)
		END
	END
	SELECT 
	@valid = 1,
	@message = @stepInput
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
