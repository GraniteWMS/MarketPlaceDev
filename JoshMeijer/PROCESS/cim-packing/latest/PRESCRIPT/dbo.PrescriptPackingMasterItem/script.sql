CREATE PROCEDURE [dbo].[PrescriptPackingMasterItem] (
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
SELECT @stepInput = Value
FROM @input
WHERE Name = 'StepInput'
DECLARE @DocumentNumber VARCHAR(100);
DECLARE @TrackingEntity VARCHAR(50);
DECLARE @DocumentID BIGINT;
DECLARE @TrackingEntityID BIGINT;
DECLARE @MasterItemID BIGINT;
DECLARE @WasPicked BIT = 0;
DECLARE @AlreadyPacked BIT = 0;
DECLARE @PickedQty DECIMAL(18,6) = 0;
DECLARE @PackedQty DECIMAL(18,6) = 0;
DECLARE @ERPLocation VARCHAR(30);
DECLARE @Location VARCHAR(30);
SELECT @DocumentNumber = Value
FROM @input
WHERE Name = 'Document';
SELECT @TrackingEntity = @stepInput;
SELECT @DocumentID = ID
FROM dbo.[Document]
WHERE [Number] = @DocumentNumber;
IF EXISTS (SELECT 1 FROM dbo.TrackingEntity WHERE Barcode = @TrackingEntity)
BEGIN
    SELECT TOP 1
        @TrackingEntityID = ID,
        @MasterItemID = MasterItem_id
    FROM dbo.TrackingEntity
    WHERE Barcode = @TrackingEntity;
    SELECT
        @PickedQty = ISNULL(SUM(ISNULL(T.ActionQty, 0)), 0)
    FROM dbo.[Transaction] T
    INNER JOIN dbo.TrackingEntity TE
        ON T.TrackingEntity_id = TE.ID
    WHERE T.[Process] IN ('PICKING')
        AND T.Document_id = @DocumentID
        AND TE.Barcode = @TrackingEntity
        AND T.ReversalTransaction_id = 0;
    IF ISNULL(@PickedQty, 0) > 0
    BEGIN
        SET @WasPicked = 1;
    END;
    SELECT
        @PackedQty = ISNULL(SUM(ISNULL(T.ActionQty, 0)), 0)
    FROM dbo.[Transaction] T
    INNER JOIN dbo.TrackingEntity TE
        ON T.FromTrackingEntity_id = TE.ID
    WHERE T.[Process] = 'PACKING'
        AND T.Document_id = @DocumentID
        AND TE.Barcode = @TrackingEntity
        AND T.ReversalTransaction_id = 0;
    IF ISNULL(@PickedQty, 0) > 0
        AND ISNULL(@PackedQty, 0) >= ISNULL(@PickedQty, 0)
    BEGIN
        SET @AlreadyPacked = 1;
    END;
    IF @WasPicked = 0
    BEGIN
        SET @Valid = 0;
        SET @Message = CONCAT(
            'This barcode (', @TrackingEntity, ') was not picked for this document (', @DocumentNumber, '). ',
            'Please scan an item that was picked.'
        );
    END
    ELSE IF @AlreadyPacked = 1
    BEGIN
        SET @Valid = 0;
        SET @Message = CONCAT(
            'This barcode (', @TrackingEntity, ') is already fully packed for document ', @DocumentNumber,
            '. Please scan a different item.'
        );
    END
    ELSE
    BEGIN
        SELECT TOP 1 @ERPLocation = DD.FromLocation
        FROM dbo.DocumentDetail DD
        WHERE DD.Document_id = @DocumentID
            AND DD.Item_id = @MasterItemID;
        SELECT TOP 1 @Location = L.Barcode
        FROM dbo.Location L
        WHERE L.ERPLocation = @ERPLocation
            AND L.Barcode LIKE '%ORD%';
        INSERT INTO @Output
        SELECT 'Location', ISNULL(@Location, '');
        INSERT INTO @Output
        SELECT 'CarryingEntity', @DocumentNumber;
        SET @Valid = 1;
        SET @Message = CONCAT(
            'Scan accepted. Barcode ', @TrackingEntity,
            ' was picked and is ready to pack. (PickedQty: ', ISNULL(@PickedQty,0),
            ', PackedQty: ', ISNULL(@PackedQty,0), ')'
        );
    END;
END
ELSE
BEGIN
    SET @valid = 0;
    SET @message = CONCAT('Not a valid tracking entity ', @TrackingEntity);
END
INSERT INTO @Output
SELECT 'Message', @message;
INSERT INTO @Output
SELECT 'Valid', @valid;
INSERT INTO @Output
SELECT 'StepInput', @stepInput;
SELECT * FROM @Output;
