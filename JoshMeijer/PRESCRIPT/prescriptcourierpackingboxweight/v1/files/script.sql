CREATE PROCEDURE [dbo].[PrescriptCourierPackingBoxWeight] (
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
DECLARE @WeightText VARCHAR(50);
DECLARE @Weight DECIMAL(19,6);
DECLARE @CourierBoxID BIGINT;
DECLARE @CourierBoxTypeID BIGINT;
DECLARE @MaxWeight DECIMAL(19,6);
DECLARE @AuditUser VARCHAR(50);
DECLARE @LookupProcess VARCHAR(50);
DECLARE @LookupStep VARCHAR(30);
SET @LookupProcess = 'COURIERPACKING';
SET @LookupStep = 'zConfirmation';
SET @WeightText = REPLACE(LTRIM(RTRIM(ISNULL(@stepInput, ''))), ',', '.');
SELECT TOP 1
    @BoxBarcode = LTRIM(RTRIM([Value]))
FROM @input
WHERE [Name] = 'BoxBarcode';
SELECT TOP 1
    @AuditUser = LEFT(CAST([Value] AS VARCHAR(50)), 50)
FROM @input
WHERE [Name] IN ('User');
SET @AuditUser = ISNULL(NULLIF(@AuditUser, ''), 'SYSTEM');
IF ISNULL(@WeightText, '') = ''
BEGIN
    SET @valid = 1;
    SET @message = '';
    GOTO Finish;
END;
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
      AND [Value] IN ('YES', 'NO')
)
DELETE FROM DuplicateLookup
WHERE RowNum > 1;
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.ProcessStepLookup
    WHERE [Process] = @LookupProcess
      AND [ProcessStep] = @LookupStep
      AND ISNULL([UserName], '') = ''
      AND [Value] = 'YES'
)
BEGIN
    INSERT INTO dbo.ProcessStepLookup
    (
          [Value]
        , [Description]
        , [Process]
        , [ProcessStep]
        , [UserName]
    )
    VALUES
    (
          'YES'
        , 'Yes - finalise courier box'
        , @LookupProcess
        , @LookupStep
        , NULL
    );
END;
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.ProcessStepLookup
    WHERE [Process] = @LookupProcess
      AND [ProcessStep] = @LookupStep
      AND ISNULL([UserName], '') = ''
      AND [Value] = 'NO'
)
BEGIN
    INSERT INTO dbo.ProcessStepLookup
    (
          [Value]
        , [Description]
        , [Process]
        , [ProcessStep]
        , [UserName]
    )
    VALUES
    (
          'NO'
        , 'No - do not finalise'
        , @LookupProcess
        , @LookupStep
        , NULL
    );
END;
UPDATE dbo.ProcessStepLookup
SET [Description] = 'Yes - finalise courier box'
WHERE [Process] = @LookupProcess
  AND [ProcessStep] = @LookupStep
  AND ISNULL([UserName], '') = ''
  AND [Value] = 'YES';
UPDATE dbo.ProcessStepLookup
SET [Description] = 'No - do not finalise'
WHERE [Process] = @LookupProcess
  AND [ProcessStep] = @LookupStep
  AND ISNULL([UserName], '') = ''
  AND [Value] = 'NO';
IF ISNULL(@BoxBarcode, '') = ''
BEGIN
    SET @valid = 0;
    SET @message = 'Please scan a box barcode first.';
    GOTO Finish;
END;
IF @WeightText LIKE '% %'
BEGIN
    SET @valid = 0;
    SET @message = 'Weight may not contain spaces.';
    GOTO Finish;
END;
IF PATINDEX('%[^0-9.]%', @WeightText) > 0
BEGIN
    SET @valid = 0;
    SET @message = 'Weight must be a valid number.';
    GOTO Finish;
END;
IF @WeightText LIKE '%.%.%'
BEGIN
    SET @valid = 0;
    SET @message = 'Weight has too many decimal points.';
    GOTO Finish;
END;
IF LEFT(@WeightText, 1) = '.'
   OR RIGHT(@WeightText, 1) = '.'
BEGIN
    SET @valid = 0;
    SET @message = 'Weight must be a valid number.';
    GOTO Finish;
END;
SET @Weight = CAST(@WeightText AS DECIMAL(19,6));
IF @Weight <= 0
BEGIN
    SET @valid = 0;
    SET @message = 'Weight must be greater than zero.';
    GOTO Finish;
END;
SELECT TOP 1
      @CourierBoxID = CB.ID
    , @CourierBoxTypeID = CB.CourierBoxType_id
    , @MaxWeight = CBT.MaxWeight
FROM dbo.Custom_CourierBox CB
LEFT JOIN dbo.Custom_CourierBoxType CBT
    ON CBT.ID = CB.CourierBoxType_id
WHERE CB.BoxBarcode = @BoxBarcode
  AND ISNULL(CB.IsFinalised, 0) = 0;
IF @CourierBoxID IS NULL
BEGIN
    SET @valid = 0;
    SET @message = 'Courier box could not be found.';
    GOTO Finish;
END;
IF @CourierBoxTypeID IS NULL
BEGIN
    SET @valid = 0;
    SET @message = 'Please select a box type first.';
    GOTO Finish;
END;
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.Custom_CourierBoxTrackingEntity
    WHERE CourierBox_id = @CourierBoxID
)
BEGIN
    SET @valid = 0;
    SET @message = 'Please scan stock before capturing weight.';
    GOTO Finish;
END;
IF @MaxWeight IS NOT NULL
   AND @Weight > @MaxWeight
BEGIN
    SET @valid = 0;
    SET @message = 'Weight exceeds the selected box max weight.';
    GOTO Finish;
END;
UPDATE dbo.Custom_CourierBox
SET
      Weight = @Weight
    , WeightUOM = 'KG'
    , AuditDate = GETDATE()
    , AuditUser = @AuditUser
    , Version = ISNULL(Version, 0) + 1
WHERE ID = @CourierBoxID;
SET @stepInput = CAST(@Weight AS VARCHAR(50));
SET @message = 'Courier box weight updated.';
Finish:
    INSERT INTO @Output
    SELECT 'Message', @message
    INSERT INTO @Output
    SELECT 'Valid', @valid
    INSERT INTO @Output
    SELECT 'StepInput', @stepInput
    SELECT * FROM @Output
