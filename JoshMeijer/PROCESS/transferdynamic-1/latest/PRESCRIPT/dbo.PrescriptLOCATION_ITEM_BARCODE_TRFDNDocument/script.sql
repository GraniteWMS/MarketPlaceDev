CREATE PROCEDURE [dbo].[PrescriptLOCATION_ITEM_BARCODE_TRFDNDocument] (
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

DECLARE @NextTransferNumber varchar (30)

SELECT @NextTransferNumber = (SELECT Prefix + LEFT('000000',6-LEN(NextBarcode)) + CAST(NextBarcode as varchar) FROM BarcodeMaster WHERE Name = 'DOCUMENTTRANSFER')

IF (@stepInput = @NextTransferNumber)
BEGIN

	UPDATE BarcodeMaster 
	SET NextBarcode = CONVERT(INT,NextBarcode) + 1 
	WHERE Name = 'DOCUMENTTRANSFER'

	INSERT INTO Document (Number, Type, Status, CreateDate, Site, ERPSyncFailed)
	SELECT @NextTransferNumber, 'TRANSFER', 'RELEASED', GETDATE(), '', 0

END

	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput

	SELECT * FROM @Output
