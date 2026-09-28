CREATE PROCEDURE [dbo].[PrescriptDelinkCourierPackingzConfirmation] (
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
SET @valid = 1;
SET @message = '';
DECLARE @BoxBarcode VARCHAR(100);
DECLARE @DocumentNumber VARCHAR(50);
DECLARE @Confirmation VARCHAR(20);
DECLARE @CourierBoxID BIGINT;
DECLARE @DocumentID BIGINT;
DECLARE @AuditUser VARCHAR(50);
DECLARE @RemovedBarcodeCount INT;
SET @RemovedBarcodeCount = 0;
SET @Confirmation = UPPER(LTRIM(RTRIM(ISNULL(@stepInput, ''))));
SELECT TOP 1
    @BoxBarcode = UPPER(LTRIM(RTRIM([Value])))
FROM @input
WHERE [Name] = 'BoxBarcode';
SELECT TOP 1
    @DocumentNumber = LTRIM(RTRIM([Value]))
FROM @input
WHERE [Name] = 'Document';
SELECT TOP 1
    @AuditUser = LEFT(CAST([Value] AS VARCHAR(50)), 50)
FROM @input
WHERE [Name] IN ('User');
SET @AuditUser = ISNULL(NULLIF(@AuditUser, ''), 'SYSTEM');
IF @Confirmation NOT IN ('YES', 'NO')
BEGIN
    SET @valid = 0;
    SET @message = 'Please select YES or NO.';
    GOTO Finish;
END;
IF @Confirmation = 'NO'
BEGIN
    SET @valid = 1;
    SET @message = 'Sales Order was not removed.';
    GOTO Finish;
END;
SELECT TOP 1
    @CourierBoxID = ID
FROM dbo.Custom_CourierBox
WHERE BoxBarcode = @BoxBarcode;
SELECT TOP 1
    @DocumentID = ID
FROM dbo.[Document]
WHERE [Number] = @DocumentNumber
ORDER BY ID DESC;
IF @CourierBoxID IS NULL
BEGIN
    SET @valid = 0;
    SET @message = 'Courier box was not found.';
    GOTO Finish;
END;
IF @DocumentID IS NULL
BEGIN
    SET @valid = 0;
    SET @message = 'Sales Order was not found.';
    GOTO Finish;
END;
BEGIN TRY
    BEGIN TRANSACTION;
        SELECT
            @RemovedBarcodeCount = COUNT(*)
        FROM dbo.Custom_CourierBoxTrackingEntity CBTE
        WHERE CBTE.CourierBox_id = @CourierBoxID
          AND EXISTS
          (
              SELECT 1
              FROM dbo.[Transaction] T
              WHERE T.Document_id = @DocumentID
                AND T.TrackingEntity_id = CBTE.TrackingEntity_id
                AND UPPER(T.[Type]) = 'PICK'
                AND ISNULL(T.ReversalTransaction_id, 0) = 0
                AND ISNULL(T.ActionQty, 0) > 0
          );
        DELETE CBTE
        FROM dbo.Custom_CourierBoxTrackingEntity CBTE
        WHERE CBTE.CourierBox_id = @CourierBoxID
          AND EXISTS
          (
              SELECT 1
              FROM dbo.[Transaction] T
              WHERE T.Document_id = @DocumentID
                AND T.TrackingEntity_id = CBTE.TrackingEntity_id
                AND UPPER(T.[Type]) = 'PICK'
                AND ISNULL(T.ReversalTransaction_id, 0) = 0
                AND ISNULL(T.ActionQty, 0) > 0
          );
        DELETE FROM dbo.Custom_CourierBoxDocument
        WHERE CourierBox_id = @CourierBoxID
          AND Document_id = @DocumentID;
        
        UPDATE dbo.Custom_CourierBox
        SET
              Weight = NULL
            , VolumetricWeight = NULL
            , AuditDate = GETDATE()
            , AuditUser = @AuditUser
            , Version = ISNULL(Version, 0) + 1
        WHERE ID = @CourierBoxID;
    COMMIT TRANSACTION;
    SET @message =
        'Sales Order removed from courier box. Barcodes removed: '
        + CAST(@RemovedBarcodeCount AS VARCHAR(20))
        + '.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    SET @valid = 0;
    SET @message = 'Could not remove Sales Order from courier box.';
END CATCH;
Finish:
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
