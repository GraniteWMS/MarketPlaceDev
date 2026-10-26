CREATE PROCEDURE [dbo].[PrescriptPutawayItemLocationValidation] (
    @input dbo.ScriptInputParameters READONLY
)
AS
DECLARE @Output TABLE (
    Name VARCHAR(MAX),
    Value VARCHAR(MAX)
);
SET NOCOUNT ON;
DECLARE @LocationInput NVARCHAR(MAX);
DECLARE @TrackingEntityInput NVARCHAR(MAX);
DECLARE @ItemCode VARCHAR(50);
DECLARE @LocationBarcode VARCHAR(50);
DECLARE @LocationName VARCHAR(50);
SELECT @LocationInput = Value FROM @input WHERE Name = 'Location';
SELECT @TrackingEntityInput = Value FROM @input WHERE Name = 'TrackingEntity';
SELECT @ItemCode = mi.Code
FROM TrackingEntity te
INNER JOIN MasterItem mi ON te.MasterItem_id = mi.ID
WHERE te.Barcode = @TrackingEntityInput;
SELECT @LocationBarcode = l.Barcode,
       @LocationName = l.Name
FROM Location l
WHERE l.Barcode = @LocationInput
   OR l.Name = @LocationInput;
IF @ItemCode IS NULL
BEGIN
    INSERT INTO @Output SELECT 'Valid', '0';
    INSERT INTO @Output SELECT 'Message', 'Tracking entity not found: ' + ISNULL(@TrackingEntityInput, '(empty)');
END
ELSE IF @LocationBarcode IS NULL
BEGIN
    INSERT INTO @Output SELECT 'Valid', '0';
    INSERT INTO @Output SELECT 'Message', 'Location not found: ' + ISNULL(@LocationInput, '(empty)');
END
ELSE IF LEFT(@LocationBarcode, LEN(@ItemCode)) <> @ItemCode
BEGIN
    INSERT INTO @Output SELECT 'Valid', '0';
    INSERT INTO @Output SELECT 'Message', 
        'Item code ' + @ItemCode + ' does not match location ' + @LocationName 
        + ' (barcode: ' + @LocationBarcode + '). Location barcode must start with the item code.';
END
ELSE
BEGIN
    
    INSERT INTO @Output SELECT 'Valid', '1';
END
SELECT * FROM @Output;
