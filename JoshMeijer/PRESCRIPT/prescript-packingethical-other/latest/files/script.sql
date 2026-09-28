CREATE PROCEDURE [dbo].[Prescript_PackingEthical_Other] (
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
SELECT @stepInput = UPPER(Value) FROM @input WHERE Name = 'StepInput' 
DECLARE
@NoBox int = ISNULL(TRY_CONVERT(INT, (SELECT [Value] FROM @input WHERE [Name] = 'Box')), 0),
@NoIceBox int = ISNULL(TRY_CONVERT(INT, (SELECT [Value] FROM @input WHERE [Name] = 'IceBox')), 0),
@NoPacket int = ISNULL(TRY_CONVERT(INT, (SELECT [Value] FROM @input WHERE [Name] = 'Packet')), 0),
@NoOther int = ISNULL(TRY_CONVERT(INT, @stepInput), 0),
@TotalBarcodesToPrint int,
@NextBarcode bigint,
@Prefix varchar(5),
@Length bigint,
@Barcodes nvarchar(4000),
@User varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'User'),
@Printer varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'PrinterName'),
@CurrentDateTime datetime = GETDATE(),
@LocationID bigint = (SELECT ID FROM dbo.[Location] WHERE Barcode = 'ETHICAL PACKING')
DECLARE
@UserID bigint = (SELECT ID FROM Users WHERE [Name] = @User)
DECLARE @NewPalletBarcodes TABLE
(
Barcode varchar(50),
[Type] varchar(50)
)
SELECT @stepInput = CONCAT(
'Box - ', @NoBox, ' | ',
'Ice Box - ', @NoIceBox, ' | ',
'Packet - ', @NoPacket, ' | ',
'Other - ', @NoOther
)
SET @TotalBarcodesToPrint = 
@NoBox + 
@NoIceBox + 
IIF(@NoOther = 0, 0, 1) +
@NoPacket;
BEGIN TRY
	SELECT 
	@Prefix = [Prefix],
	@Length = [Length],
	@NextBarcode = [NextBarcode]
	FROM dbo.BarcodeMaster
	WHERE [Name] = 'BOX';
	INSERT INTO @NewPalletBarcodes(Barcode, [Type])
	SELECT CONCAT(@Prefix, REPLICATE('0', @Length - LEN(SeqID)), SeqID), [Type]
	FROM
	(
	SELECT 
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @NextBarcode AS SeqID,
	[Type]
	FROM
	(
	SELECT 'BOX' AS [Type] FROM GENERATE_SERIES(1, IIF(@NoBox = 0, NULL, @NoBox))
	UNION ALL
	SELECT 'ICE BOX' AS [Type] FROM GENERATE_SERIES(1, IIF(@NoIceBox = 0, NULL, @NoIceBox))
	UNION ALL
	SELECT 'PACKET' AS [Type] FROM GENERATE_SERIES(1, IIF(@NoPacket = 0, NULL, @NoPacket))
	UNION ALL
	SELECT 'OTHER' AS [Type] FROM GENERATE_SERIES(1, IIF(@NoOther = 0, NULL, 1))
	) PackingTypes
	) BarcodeSeqAndTypes
	UPDATE dbo.BarcodeMaster
	SET NextBarcode += @TotalBarcodesToPrint
	WHERE [Name] = 'BOX'
	INSERT INTO dbo.CarryingEntity(Barcode, CreateDate, Location_id, AuditUser, AuditDate, [PhysicalType])
	SELECT Barcode, @CurrentDateTime, @LocationID, @User, @CurrentDateTime, [Type]
	FROM @NewPalletBarcodes
	SELECT @Barcodes = STRING_AGG(Barcode, ',') FROM @NewPalletBarcodes
	EXECUTE [dbo].[clr_PrintLabel] 
	 @barcode = NULL
	,@barcodes = @Barcodes
	,@labelName = 'PackingBox.zpl'
	,@numberOfLabels = 1
	,@printerName = @Printer
	,@type = 'BOX'
	,@userID = @UserID
	,@success = @valid OUTPUT
	,@message = @message OUTPUT
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
