CREATE   PROCEDURE  [dbo].[PrescriptPackingQty] (
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
DECLARE @DocumentNumber VARCHAR(100);
DECLARE @TrackingEntity VARCHAR(50);
DECLARE @DocumentID BIGINT;
DECLARE @PickedQty INT;
DECLARE @EnteredQty INT;
DECLARE @PackedQty DECIMAL(18,6) = 0;
SELECT @DocumentNumber = Value FROM @input WHERE Name = 'Document';
SELECT @TrackingEntity = Value FROM @input WHERE Name = 'MasterItem';
SELECT @DocumentID = ID 
FROM dbo.[Document]
WHERE [Number] = @DocumentNumber;
SELECT 
    @PickedQty = SUM(ISNULL(T.ActionQty, 0))
FROM dbo.[Transaction] AS T
INNER JOIN dbo.TrackingEntity AS TE
    ON TE.ID = T.TrackingEntity_id
WHERE 
    T.Document_id = @DocumentID
    AND TE.Barcode = @TrackingEntity
    AND T.[Process] IN ('PICKING', 'PICKINGDYNAMIC')
	AND T.ReversalTransaction_id = 0
SELECT 
    @PackedQty = SUM(ISNULL(T.ActionQty, 0))
FROM dbo.[Transaction] AS T
INNER JOIN dbo.TrackingEntity AS TE
    ON TE.ID = T.FromTrackingEntity_id
WHERE 
    T.Document_id = @DocumentID
    AND TE.Barcode = @TrackingEntity
    AND T.[Process] = 'PACKING'
	AND T.ReversalTransaction_id = 0
SET @PickedQty = ISNULL(@PickedQty,0) - ISNULL(@PackedQty,0);
IF @PickedQty < 0 SET @PickedQty = 0;
SET @EnteredQty = TRY_CAST(@stepInput AS INT);
IF @EnteredQty IS NULL OR @EnteredQty = 0
BEGIN
    SET @Valid = 0;
    SET @Message = 'Please enter a valid quantity.';
END
ELSE IF @PickedQty IS NULL
BEGIN
    SET @Valid = 0;
    SET @Message = CONCAT(
        'No picking record found for barcode ', @TrackingEntity, 
        ' on document ', @DocumentNumber, '. Please verify the item.'
    );
END
ELSE IF @EnteredQty <> @PickedQty
BEGIN
    SET @Valid = 0;
    SET @Message = CONCAT(
        'Incorrect quantity entered. Picked quantity for barcode ', @TrackingEntity, 
        ' is ', @PickedQty, 
        '. You entered ', @EnteredQty, 
        '. Please enter the same quantity that was picked.'
    );
END
ELSE
BEGIN
    SET @Valid = 1;
    SET @Message = ''
END;
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	INSERT INTO @Output
	SELECT 'CarryingEntity', @DocumentNumber
	SELECT * FROM @Output
