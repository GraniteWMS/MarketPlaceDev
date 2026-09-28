CREATE PROCEDURE [dbo].[PrescriptCourierPackingTrackingEntity] (
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
DECLARE @TrackingEntityBarcode VARCHAR(100);
DECLARE @CourierBoxID BIGINT;
DECLARE @TrackingEntityID BIGINT;
DECLARE @ExistingCourierBoxID BIGINT;
DECLARE @ExistingBoxBarcode VARCHAR(100);
DECLARE @AuditUser VARCHAR(50);
DECLARE @BarcodeCount INT;
SET @BarcodeCount = 0;
SET @TrackingEntityBarcode = LTRIM(RTRIM(ISNULL(@stepInput, '')));
SELECT TOP 1
    @BoxBarcode = LTRIM(RTRIM([Value]))
FROM @input
WHERE [Name] = 'BoxBarcode';
SELECT TOP 1
    @AuditUser = LEFT(CAST([Value] AS VARCHAR(50)), 50)
FROM @input
WHERE [Name] IN ('User');
SET @AuditUser = ISNULL(NULLIF(@AuditUser, ''), 'SYSTEM');
IF ISNULL(@BoxBarcode, '') = ''
BEGIN
    SET @valid = 0;
    SET @message = 'Please scan a box barcode first.';
    GOTO Finish;
END;
SELECT TOP 1
    @CourierBoxID = ID
FROM dbo.Custom_CourierBox
WHERE BoxBarcode = @BoxBarcode
  AND ISNULL(IsFinalised, 0) = 0;
IF @CourierBoxID IS NULL
BEGIN
    SET @valid = 0;
    SET @message = 'Courier box could not be found.';
    GOTO Finish;
END;
IF ISNULL(@TrackingEntityBarcode, '') = ''
BEGIN
    SET @valid = 1;
    SET @message = '';
    GOTO Finish;
END;
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.Custom_CourierBoxDocument
    WHERE CourierBox_id = @CourierBoxID
)
BEGIN
    SET @valid = 0;
    SET @message = 'Please scan an order before scanning stock.';
    GOTO Finish;
END;
SELECT TOP 1
    @TrackingEntityID = ID
FROM dbo.TrackingEntity
WHERE Barcode = @TrackingEntityBarcode
ORDER BY ID DESC;
IF @TrackingEntityID IS NULL
BEGIN
    SET @valid = 0;
    SET @message = 'Tracking entity could not be found.';
    GOTO Finish;
END;
SELECT TOP 1
      @ExistingCourierBoxID = CBTE.CourierBox_id
    , @ExistingBoxBarcode = CB.BoxBarcode
FROM dbo.Custom_CourierBoxTrackingEntity CBTE
INNER JOIN dbo.Custom_CourierBox CB
    ON CB.ID = CBTE.CourierBox_id
WHERE CourierBox_id = @CourierBoxID
  AND TrackingEntity_id = @TrackingEntityID
IF @ExistingCourierBoxID IS NOT NULL
BEGIN
    IF @ExistingCourierBoxID = @CourierBoxID
    BEGIN
        SET @valid = 0;
        SET @message = 'Tracking entity already scanned into this box.';
        GOTO Finish;
    END
    ELSE
    BEGIN
        SET @valid = 0;
        SET @message = 'Tracking entity already scanned into another box.';
        GOTO Finish;
    END;
END;
BEGIN TRY
    INSERT INTO dbo.Custom_CourierBoxTrackingEntity
    (
          CourierBox_id
        , TrackingEntity_id
        , ScanDate
        , ScannedUser
        , AuditDate
        , AuditUser
        , Version
    )
    VALUES
    (
          @CourierBoxID
        , @TrackingEntityID
        , GETDATE()
        , @AuditUser
        , GETDATE()
        , @AuditUser
        , 1
    );
    SET @stepInput = @TrackingEntityBarcode;
    SET @message = 'Tracking entity scanned into courier box.';
END TRY
BEGIN CATCH
    SET @valid = 0;
    IF ERROR_NUMBER() IN (2601, 2627)
    BEGIN
        SET @message = 'Tracking entity already scanned into a courier box.';
    END
    ELSE
    BEGIN
        SET @message = 'Could not scan tracking entity into box.';
    END;
END CATCH;
Finish:
IF @CourierBoxID IS NULL
   AND ISNULL(@BoxBarcode, '') <> ''
BEGIN
    SELECT TOP 1
        @CourierBoxID = ID
    FROM dbo.Custom_CourierBox
    WHERE BoxBarcode = @BoxBarcode
      AND ISNULL(IsFinalised, 0) = 0;
END;
IF @CourierBoxID IS NOT NULL
BEGIN
    SELECT
        @BarcodeCount = COUNT(*)
    FROM dbo.Custom_CourierBoxTrackingEntity
    WHERE CourierBox_id = @CourierBoxID;
END;
DELETE FROM dbo.ProcessStepLookup
WHERE [Process] = 'COURIERPACKING'
  AND [ProcessStep] = 'zConfirmation'
  AND ISNULL([UserName], '') = ''
  AND [Value] IN ('YES', 'NO');
    INSERT INTO @Output
    SELECT 'Message', @message
    INSERT INTO @Output
    SELECT 'Valid', @valid
    INSERT INTO @Output
    SELECT 'StepInput', @stepInput
    INSERT INTO @Output
    SELECT 'BarcodeCount', CAST(@BarcodeCount AS VARCHAR(20))
    SELECT * FROM @Output
