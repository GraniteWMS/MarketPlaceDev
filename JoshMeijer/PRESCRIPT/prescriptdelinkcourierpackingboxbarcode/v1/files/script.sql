CREATE PROCEDURE [dbo].[PrescriptDelinkCourierPackingBoxBarcode] (
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
SET @BoxBarcode = UPPER(LTRIM(RTRIM(ISNULL(@stepInput, ''))));
IF @BoxBarcode = ''
BEGIN
    SET @valid = 0;
    SET @message = 'Please scan or enter a box barcode.';
    GOTO Finish;
END;
SELECT TOP 1
      @CourierBoxID = ID
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
    SET @message = 'Courier box is finalised and cannot be changed.';
    GOTO Finish;
END;
SET @stepInput = @BoxBarcode;
SET @message = 'Courier box loaded.';
Finish:
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
