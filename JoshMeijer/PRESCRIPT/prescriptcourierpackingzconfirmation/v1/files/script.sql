CREATE PROCEDURE [dbo].[PrescriptCourierPackingzConfirmation] (
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
DECLARE @Confirmation VARCHAR(20);
DECLARE @CourierBoxID BIGINT;
DECLARE @CourierBoxTypeID BIGINT;
DECLARE @Weight DECIMAL(19,6);
DECLARE @IsFinalised BIT;
DECLARE @AuditUser VARCHAR(50);
SET @Confirmation = UPPER(LTRIM(RTRIM(ISNULL(@stepInput, ''))));
SELECT TOP 1
    @BoxBarcode = LTRIM(RTRIM([Value]))
FROM @input
WHERE [Name] = 'BoxBarcode';
SELECT TOP 1
    @AuditUser = LEFT(CAST([Value] AS VARCHAR(50)), 50)
FROM @input
WHERE [Name] IN ('User');
SET @AuditUser = ISNULL(NULLIF(@AuditUser, ''), 'SYSTEM');
IF @Confirmation = ''
BEGIN
    SET @valid = 1;
    SET @message = '';
    GOTO Finish;
END;
IF @Confirmation <> 'YES'
BEGIN
    SET @valid = 0;
    SET @message = 'Please select YES to finalise the courier box.';
    GOTO Finish;
END;
IF ISNULL(@BoxBarcode, '') = ''
BEGIN
    SET @valid = 0;
    SET @message = 'Please scan a box barcode first.';
    GOTO Finish;
END;
SELECT TOP 1
      @CourierBoxID = ID
    , @CourierBoxTypeID = CourierBoxType_id
    , @Weight = Weight
    , @IsFinalised = IsFinalised
FROM dbo.Custom_CourierBox
WHERE BoxBarcode = @BoxBarcode;
IF @CourierBoxID IS NULL
BEGIN
    SET @valid = 0;
    SET @message = 'Courier box could not be found.';
    GOTO Finish;
END;
IF ISNULL(@IsFinalised, 0) = 1
BEGIN
    SET @valid = 0;
    SET @message = 'This courier box is already finalised.';
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
    FROM dbo.Custom_CourierBoxDocument
    WHERE CourierBox_id = @CourierBoxID
)
BEGIN
    SET @valid = 0;
    SET @message = 'Please scan at least one order.';
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
    SET @message = 'Please scan stock into the box.';
    GOTO Finish;
END;
IF ISNULL(@Weight, 0) <= 0
BEGIN
    SET @valid = 0;
    SET @message = 'Please capture the final box weight.';
    GOTO Finish;
END;
UPDATE dbo.Custom_CourierBox
SET
      IsFinalised = 1
    , FinalisedDate = GETDATE()
    , FinalisedUser = @AuditUser
    , AuditDate = GETDATE()
    , AuditUser = @AuditUser
    , Version = ISNULL(Version, 0) + 1
WHERE ID = @CourierBoxID;
DELETE FROM dbo.ProcessStepLookup
WHERE [Process] = 'COURIER PACKING'
  AND [ProcessStep] = 'zConfirmation'
  AND ISNULL([UserName], '') = ''
  AND [Value] IN ('YES', 'NO');
SET @message = 'Courier box finalised successfully.';
Finish:
    INSERT INTO @Output
    SELECT 'Message', @message
    INSERT INTO @Output
    SELECT 'Valid', @valid
    INSERT INTO @Output
    SELECT 'StepInput', @stepInput
    SELECT * FROM @Output
