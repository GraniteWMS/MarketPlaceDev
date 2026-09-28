CREATE PROCEDURE [dbo].[Prescript_Transfer_Step200] (
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
@UserID bigint = (SELECT ID FROM Users WHERE [Name] = (SELECT [Value] FROM @input WHERE [Name] = 'User')),
@DocumentID bigint = (SELECT ID FROM Document WHERE Number = (SELECT [Value] FROM @input WHERE [Name] = 'Document')),
@ScannedBarcode varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'TrackingEntity'),
@Printer varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'PrinterName'),
@LastTransferredBarcodeID bigint,
@LastTransferredBarcode varchar(50),
@success bit
SELECT TOP 1
@LastTransferredBarcodeID = T.TrackingEntity_id,
@LastTransferredBarcode = TE.Barcode
FROM dbo.[Transaction] T
INNER JOIN TrackingEntity TE ON T.TrackingEntity_id = TE.ID
WHERE T.[Document_id] = @DocumentID
AND T.[User_id] = @UserID
AND T.[Type] = 'TRANSFER'
AND T.[Process] = 'TRANSFER'
ORDER BY T.ID DESC
BEGIN TRY
	IF ISNULL(@LastTransferredBarcodeID, 0) = 0
	BEGIN
		RAISERROR('Could not determine last barcode transferred on this document', 16, 1);
	END
	IF ISNULL(@LastTransferredBarcode, '') <> ISNULL(@ScannedBarcode, '')
	BEGIN 
		EXECUTE [dbo].[clr_PrintLabel] 
	   @barcode = @LastTransferredBarcode
	  ,@barcodes = NULL
	  ,@labelName = 'TrackingEntity.zpl'
	  ,@numberOfLabels = 1
	  ,@printerName = @Printer
	  ,@type = 'TRACKINGENTITY'
	  ,@userID = @UserID
	  ,@success = @success OUTPUT
	  ,@message = @message OUTPUT
	END
	UPDATE TrackingEntity
	SET OnHold = 1
	WHERE ID = @LastTransferredBarcodeID
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
