CREATE   PROCEDURE [dbo].[PrescriptReceivingNoEntities] (
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
DECLARE @NoEntities decimal(19,4)
DECLARE @Qty decimal(19,4)
DECLARE @Document_id bigint
DECLARE @MasterItem_id bigint
DECLARE @LocationName varchar(100)
DECLARE @ERPLocation varchar(100)
DECLARE @OutstandingQty decimal(19,4)
DECLARE @TotalQty decimal(19,4)
DECLARE @Document varchar(40)
DECLARE @MasterItemCode varchar(50)
IF TRY_CONVERT(decimal(19,4), @stepInput) IS NULL
BEGIN
    SET @message = 'Please capture a valid numeric or decimal value.'
    SET @valid = 0
    GOTO Finish
END
SET @NoEntities = TRY_CONVERT(decimal(19,4), @stepInput)
IF @NoEntities <= 0 AND @NoEntities >= 101
BEGIN
    SET @message = 'No of entities must be greater than 0 and less that 100.'
    SET @valid = 0
    GOTO Finish
END
SELECT @Qty = REPLACE(Value, ',','.') 
FROM @input 
WHERE Name = 'Qty'
SELECT @LocationName = Value
FROM @input
WHERE Name = 'Location'
SELECT @Document = Value
FROM @input
WHERE Name = 'Document'
SELECT @MasterItemCode = Value
FROM @input
WHERE Name = 'MasterItem'
SELECT TOP 1
    @Document_id = ID 
FROM Document 
WHERE Number = @Document
SELECT TOP 1
    @MasterItem_id = ID 
FROM MasterItem
WHERE Code = @MasterItemCode
SELECT TOP 1
    @ERPLocation = L.ERPLocation
FROM dbo.Location L WITH (NOLOCK)
WHERE L.Name = @LocationName
   OR L.Barcode = @LocationName
SELECT
    @OutstandingQty = SUM(ISNULL(DD.Qty, 0) - ISNULL(DD.ActionQty, 0))
FROM dbo.DocumentDetail DD WITH (NOLOCK)
WHERE DD.Document_id = @Document_id
  AND DD.Item_id = @MasterItem_id
  AND (DD.ToLocation = @ERPLocation OR DD.FromLocation = @ERPLocation)
  AND ISNULL(DD.Cancelled, 0) = 0
SET @OutstandingQty = ISNULL(@OutstandingQty, 0)
SET @TotalQty = ISNULL(@Qty, 0) * @NoEntities
IF @TotalQty > @OutstandingQty
BEGIN
    SET @valid = 0
    SET @message = CONCAT(
        'Entered quantity is too high. Total quantity ',
        CONVERT(varchar(50), @TotalQty),
        ' may not be greater than outstanding quantity ',
        CONVERT(varchar(50), @OutstandingQty),
        '.'
    )
    GOTO Finish
END
SET @valid = 1
SET @message = ''
Finish:
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output