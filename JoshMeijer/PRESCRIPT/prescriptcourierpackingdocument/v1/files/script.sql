CREATE PROCEDURE [dbo].[PrescriptCourierPackingDocument] (
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
DECLARE @CourierBoxID BIGINT;
DECLARE @DocumentID BIGINT;
DECLARE @AuditUser VARCHAR(50);
SET @DocumentNumber = LTRIM(RTRIM(ISNULL(@stepInput, '')));
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
IF ISNULL(@DocumentNumber, '') = ''
BEGIN
    SET @valid = 0;
    SET @message = 'Please scan or enter a document.';
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
DELETE FROM dbo.ProcessStepLookup
WHERE [Process] = 'COURIERPACKING'
  AND [ProcessStep] = 'BoxType'
  AND ISNULL([UserName], '') = ''
  AND [Value] IN
  (
      SELECT CBT.Code
      FROM dbo.Custom_CourierBoxType CBT
  );
SELECT TOP 1
    @DocumentID = ID
FROM dbo.[Document]
WHERE [Number] = @DocumentNumber
ORDER BY ID DESC;
IF @DocumentID IS NULL
BEGIN
    SET @valid = 0;
    SET @message = 'Document could not be found.';
    GOTO Finish;
END;
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.Custom_CourierBoxDocument
    WHERE CourierBox_id = @CourierBoxID
      AND Document_id = @DocumentID
)
BEGIN
    INSERT INTO dbo.Custom_CourierBoxDocument
    (
          CourierBox_id
        , Document_id
        , ScanDate
        , ScannedUser
        , AuditDate
        , AuditUser
        , Version
    )
    VALUES
    (
          @CourierBoxID
        , @DocumentID
        , GETDATE()
        , @AuditUser
        , GETDATE()
        , @AuditUser
        , 1
    );
    SET @message = 'Document linked to courier box.';
END
ELSE
BEGIN
    SET @message = 'Document already linked to courier box.';
END;
Finish:
    INSERT INTO @Output
    SELECT 'Message', @message
    INSERT INTO @Output
    SELECT 'Valid', @valid
    INSERT INTO @Output
    SELECT 'StepInput', @stepInput
    SELECT * FROM @Output
