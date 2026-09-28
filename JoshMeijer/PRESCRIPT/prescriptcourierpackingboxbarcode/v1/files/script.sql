CREATE PROCEDURE [dbo].[PrescriptCourierPackingBoxBarcode] (
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
DECLARE @CourierBoxID BIGINT;
DECLARE @IsFinalised BIT;
DECLARE @AuditUser VARCHAR(50);
DECLARE @BarcodeCount INT;
SET @BarcodeCount = 0;
SET @BoxBarcode = UPPER(LTRIM(RTRIM(ISNULL(@stepInput, ''))));
SELECT TOP 1
    @AuditUser = LEFT(CAST([Value] AS VARCHAR(50)), 50)
FROM @input
WHERE [Name] IN ('User');
SET @AuditUser = ISNULL(NULLIF(@AuditUser, ''), 'SYSTEM');
IF @BoxBarcode = ''
BEGIN
    SET @valid = 0;
    SET @message = 'Please scan or enter a box barcode.';
    GOTO Finish;
END;
IF LEN(@BoxBarcode) < 3
BEGIN
    SET @valid = 0;
    SET @message = 'Box barcode is too short.';
    GOTO Finish;
END;
IF LEN(@BoxBarcode) > 100
BEGIN
    SET @valid = 0;
    SET @message = 'Box barcode is too long.';
    GOTO Finish;
END;
IF @BoxBarcode LIKE '% %'
BEGIN
    SET @valid = 0;
    SET @message = 'Box barcode may not contain spaces.';
    GOTO Finish;
END;
IF PATINDEX('%[^A-Z0-9_-]%', @BoxBarcode) > 0
BEGIN
    SET @valid = 0;
    SET @message = 'Box barcode contains invalid characters.';
    GOTO Finish;
END;
IF @BoxBarcode IN ('TEST', 'TEST123', 'ABC', 'ABC123', '123', '000', '0000', '00000', 'NA', 'N/A')
BEGIN
    SET @valid = 0;
    SET @message = 'Invalid test box barcode scanned.';
    GOTO Finish;
END;
SELECT TOP 1
      @CourierBoxID = ID
    , @IsFinalised = IsFinalised
FROM dbo.Custom_CourierBox
WHERE BoxBarcode = @BoxBarcode;
IF @CourierBoxID IS NOT NULL
BEGIN
    IF ISNULL(@IsFinalised, 0) = 1
    BEGIN
        SET @valid = 0;
        SET @message = 'This courier box has already been finalised.';
        GOTO Finish;
    END;
    
    SET @stepInput = @BoxBarcode;
    SET @message = 'Existing courier box loaded.';
    GOTO Finish;
END;
INSERT INTO dbo.Custom_CourierBox
(
      BoxBarcode
    , Weight
    , WeightUOM
    , VolumetricWeight
    , ScanDate
    , ScannedUser
    , IsFinalised
    , FinalisedDate
    , FinalisedUser
    , Comment
    , AuditDate
    , AuditUser
    , Version
)
VALUES
(
      @BoxBarcode
    , NULL
    , 'KG'
    , NULL
    , GETDATE()
    , @AuditUser
    , 0
    , NULL
    , NULL
    , NULL
    , GETDATE()
    , @AuditUser
    , 1
);
SET @CourierBoxID = SCOPE_IDENTITY();
SET @stepInput = @BoxBarcode;
SET @message = 'Courier box created.';
Finish:
IF @CourierBoxID IS NOT NULL
BEGIN
    SELECT
        @BarcodeCount = COUNT(*)
    FROM dbo.Custom_CourierBoxTrackingEntity
    WHERE CourierBox_id = @CourierBoxID;
END;
DECLARE @LookupProcess VARCHAR(50) = 'COURIERPACKING';
DECLARE @LookupStep    VARCHAR(30) = 'BoxType';
;WITH DuplicateLookup AS
(
    SELECT
          ID
        , ROW_NUMBER() OVER
          (
              PARTITION BY
                    [Process]
                  , [ProcessStep]
                  , ISNULL([UserName], '')
                  , [Value]
              ORDER BY ID
          ) AS RowNum
    FROM dbo.ProcessStepLookup
    WHERE [Process] = @LookupProcess
      AND [ProcessStep] = @LookupStep
      AND ISNULL([UserName], '') = ''
)
DELETE FROM DuplicateLookup
WHERE RowNum > 1;
UPDATE PSL
SET
      PSL.[Description] =
        LEFT
        (
            ISNULL(NULLIF(CBT.[Description], ''), CBT.Code)
            + ' - '
            + CAST(CAST(CBT.[Length] AS DECIMAL(19,2)) AS VARCHAR(30))
            + 'x'
            + CAST(CAST(CBT.[Width] AS DECIMAL(19,2)) AS VARCHAR(30))
            + 'x'
            + CAST(CAST(CBT.[Height] AS DECIMAL(19,2)) AS VARCHAR(30))
            + ' '
            + ISNULL(CBT.DimensionUOM, '')
        , 100
        )
FROM dbo.ProcessStepLookup PSL
INNER JOIN dbo.Custom_CourierBoxType CBT
    ON CBT.Code = PSL.[Value]
WHERE PSL.[Process] = @LookupProcess
  AND PSL.[ProcessStep] = @LookupStep
  AND ISNULL(PSL.[UserName], '') = ''
  AND ISNULL(CBT.IsActive, 0) = 1;
INSERT INTO dbo.ProcessStepLookup
(
      [Value]
    , [Description]
    , [Process]
    , [ProcessStep]
)
SELECT
      CBT.Code AS [Value]
    , LEFT
      (
          ISNULL(NULLIF(CBT.[Description], ''), CBT.Code)
          + ' - '
          + CAST(CAST(CBT.[Length] AS DECIMAL(19,0)) AS VARCHAR(30))
          + 'x'
          + CAST(CAST(CBT.[Width] AS DECIMAL(19,0)) AS VARCHAR(30))
          + 'x'
          + CAST(CAST(CBT.[Height] AS DECIMAL(19,0)) AS VARCHAR(30))
          + ' '
          + ISNULL(CBT.DimensionUOM, '')
      , 100
      ) AS [Description]
    , @LookupProcess AS [Process]
    , @LookupStep AS [ProcessStep]
FROM dbo.Custom_CourierBoxType CBT
WHERE ISNULL(CBT.IsActive, 0) = 1
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.ProcessStepLookup PSL
      WHERE PSL.[Process] = @LookupProcess
        AND PSL.[ProcessStep] = @LookupStep
        AND ISNULL(PSL.[UserName], '') = ''
        AND PSL.[Value] = CBT.Code
  );
DELETE PSL
FROM dbo.ProcessStepLookup PSL
WHERE PSL.[Process] = @LookupProcess
  AND PSL.[ProcessStep] = @LookupStep
  AND ISNULL(PSL.[UserName], '') = ''
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.Custom_CourierBoxType CBT
      WHERE CBT.Code = PSL.[Value]
        AND ISNULL(CBT.IsActive, 0) = 1
  );
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
