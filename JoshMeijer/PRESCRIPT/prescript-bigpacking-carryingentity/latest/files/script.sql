CREATE PROCEDURE [dbo].[Prescript_BigPacking_CarryingEntity] (
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
@PackLocation varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'PackLocation'),
@CarryingEntity varchar(50),
@CurrentDateTime datetime = GETDATE(),
@User varchar(50) = (SELECT Value FROM @input WHERE Name = 'User'),
@Printer varchar(50) = (SELECT Value FROM @input WHERE Name = 'PrinterName'),
@success bit
DECLARE @UserID bigint = (SELECT ID FROM Users WHERE [Name] = @User)
BEGIN TRY
	IF ISNULL(@stepInput, '') = 'NEW'
	BEGIN
		IF ISNULL(@PackLocation, '') = ''
		BEGIN
			RAISERROR(N'Location must be filled in', 16, 1, @stepInput)
		END
		SELECT @CarryingEntity = CONCAT(Prefix, REPLICATE('0', [Length] - LEN(NextBarcode)), NextBarcode) 
		FROM BarcodeMaster WHERE [Name] = 'BOX'
		UPDATE BarcodeMaster 
		SET NextBarcode += 1
		WHERE [Name] = 'BOX'
		INSERT INTO CarryingEntity(Barcode, CreateDate, Location_id, AuditUser, AuditDate)
		SELECT @CarryingEntity, @CurrentDateTime, ID, @User, @CurrentDateTime
		FROM [Location] WHERE [Barcode] = @PackLocation
		SET @stepInput = @CarryingEntity
		EXECUTE [dbo].[clr_PrintLabel] 
	   @barcode = @CarryingEntity
	  ,@barcodes = NULL
	  ,@labelName = 'Pallet.zpl'
	  ,@numberOfLabels = 1
	  ,@printerName = @Printer
	  ,@type = 'PALLET'
	  ,@userID = @UserID
	  ,@success = @success OUTPUT
	  ,@message = @message OUTPUT
	END
	ELSE
	IF NOT EXISTS(SELECT ID FROM CarryingEntity WHERE Barcode = ISNULL(@stepInput, ''))
	BEGIN
		RAISERROR('Box barcode %s does not exist', 16, 1, @stepInput)
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
