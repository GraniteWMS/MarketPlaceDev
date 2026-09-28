CREATE PROCEDURE [dbo].[PrescriptDelinkCourierPackingDocument] (
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
SET @DocumentNumber = LTRIM(RTRIM(ISNULL(@stepInput, '')));
SELECT TOP 1
    @BoxBarcode = UPPER(LTRIM(RTRIM([Value])))
FROM @input
WHERE [Name] = 'BoxBarcode';
IF ISNULL(@DocumentNumber, '') = ''
BEGIN
    SET @valid = 0;
    SET @message = 'Please scan or enter a Sales Order.';
    GOTO Finish;
END;
SELECT TOP 1
    @CourierBoxID = ID
FROM dbo.Custom_CourierBox
WHERE BoxBarcode = @BoxBarcode;
IF @CourierBoxID IS NULL
BEGIN
    SET @valid = 0;
    SET @message = 'Courier box was not found from previous step.';
    GOTO Finish;
END;
SELECT TOP 1
    @DocumentID = ID
FROM dbo.[Document]
WHERE [Number] = @DocumentNumber
ORDER BY ID DESC;
IF @DocumentID IS NULL
BEGIN
    SET @valid = 0;
    SET @message = 'Sales Order could not be found.';
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
    SET @valid = 0;
    SET @message = 'Sales Order is not linked to this box.';
    GOTO Finish;
END;
SET @stepInput = @DocumentNumber;
SET @message = 'Sales Order found. Confirm removal.';
Finish:
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
