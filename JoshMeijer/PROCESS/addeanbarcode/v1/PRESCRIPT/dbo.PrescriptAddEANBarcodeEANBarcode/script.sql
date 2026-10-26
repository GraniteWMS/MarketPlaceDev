CREATE PROCEDURE [dbo].[PrescriptAddEANBarcodeEANBarcode] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 0
DECLARE @message varchar(MAX) = 'Could not capture barcode'
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @MasterItem varchar(40);
DECLARE @AliasBarcode varchar(40);
DECLARE @ExistingMasterItemCode varchar(40);
SELECT @MasterItem = Value
FROM @input
WHERE Name = 'MasterItem';
SELECT @AliasBarcode = LTRIM(RTRIM(@stepInput));
IF LEFT(@AliasBarcode, 2) <> '60'
BEGIN
    SELECT @valid = 0;
    SELECT @message = CONCAT(
        'Invalid barcode format. The barcode must start with "60". ',
        'Scanned value: ', @AliasBarcode, '.'
    );
END
ELSE IF LEN(@AliasBarcode) NOT BETWEEN 12 AND 14
BEGIN
    SELECT @valid = 0;
    SELECT @message = CONCAT(
        'Invalid barcode length. The barcode must be between 12 and 14 characters. ',
        'Current length: ', LEN(@AliasBarcode), '.'
    );
END
ELSE IF EXISTS (
        SELECT 1 
        FROM dbo.MasterItemAlias WITH (NOLOCK) 
        WHERE Code = @AliasBarcode
    )
BEGIN
    SELECT TOP (1) 
           @ExistingMasterItemCode = MI.Code
    FROM dbo.MasterItemAlias MIA WITH (NOLOCK)
    INNER JOIN dbo.MasterItem MI WITH (NOLOCK)
        ON MI.ID = MIA.MasterItem_id
    WHERE MIA.Code = @AliasBarcode;
    SELECT @valid = 0;
    SELECT @message = CONCAT(
        'This barcode is already linked to stock code ',
        ISNULL(@ExistingMasterItemCode, '(unknown)'),
        '. Barcode: ', @AliasBarcode, '.'
    );
END
ELSE
BEGIN
    
    SELECT @valid = 1;
    SELECT @message = CONCAT(
        'You are about to link barcode ',
        @AliasBarcode,
        ' to Master Item ',
        @MasterItem,
        '. Please press YES to confirm.'
    );
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
