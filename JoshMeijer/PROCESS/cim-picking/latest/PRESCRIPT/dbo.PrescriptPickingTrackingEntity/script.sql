CREATE   PROCEDURE [dbo].[PrescriptPickingTrackingEntity]
(
   @input dbo.ScriptInputParameters READONLY
)
AS
BEGIN
    DECLARE @Output TABLE
    (
        Name varchar(max),
        Value varchar(max)
    );
    SET NOCOUNT ON;
    DECLARE @valid bit = 0;
    DECLARE @message varchar(MAX) = '';
    DECLARE @stepInput varchar(MAX);
    SELECT @stepInput = Value
    FROM @input
    WHERE Name = 'StepInput';
    DECLARE @Document varchar(50);
    DECLARE @DocumentID bigint;
    DECLARE @Location varchar(30);
    DECLARE @ERPLocation varchar(30);
    DECLARE @ScannedERPLocation varchar(30);
    DECLARE @TrackingEntity varchar(50);
    DECLARE @MasterItemID bigint;
    DECLARE @CarryingEntityID bigint;
    DECLARE @TrackingEntityID bigint;
    DECLARE @TrackingEntityScannedQty decimal(19,4);
    DECLARE @RequiredQty decimal(19,4);
    DECLARE @AlreadyPickedQty decimal(19,4);
    DECLARE @RemainingQty decimal(19,4);
    DECLARE @QtyOutput decimal(19,4);
    DECLARE @DocumentDetailBatch varchar(50);
    DECLARE @trackingEntityNeedToBeScanned varchar(50);
    DECLARE @trackingEntityNeedToBeScannedQty decimal(19,4);
    DECLARE @nextTrackingEntity varchar(50);
    DECLARE @nextTrackingEntityQty decimal(19,4);
    DECLARE @locationName varchar(50);
    DECLARE @TrackingEntityBatch varchar(50);
    DECLARE @user varchar(30);
    DECLARE @Instruction nvarchar(max);
    DECLARE @RecommendationValid bit;
    DECLARE @RecommendationMessage varchar(max);
    SELECT @Document = Value
    FROM @input
    WHERE Name = 'Document';
    SELECT @user = Value
    FROM @input
    WHERE Name = 'User';
    SELECT @DocumentID = ID
    FROM dbo.Document WITH (NOLOCK)
    WHERE Number = @Document;
    IF ISNULL(@DocumentID, 0) = 0
    BEGIN
        SELECT @valid = 0;
        SELECT @message = CONCAT('Document does not exist: ', ISNULL(@Document, ''));
        GOTO ScriptEnd;
    END;
    SELECT @TrackingEntity = @stepInput;
    
    
    
    IF EXISTS (SELECT 1 FROM dbo.TrackingEntity WITH (NOLOCK) WHERE Barcode = @TrackingEntity)
    BEGIN
        SELECT TOP (1)
              @TrackingEntityID = TE.ID
            , @MasterItemID = TE.MasterItem_id
            , @TrackingEntityScannedQty = TE.Qty
            , @ScannedERPLocation = L.ERPLocation
            , @TrackingEntityBatch = TE.Batch
        FROM dbo.TrackingEntity TE WITH (NOLOCK)
        INNER JOIN dbo.Location L WITH (NOLOCK)
            ON L.ID = TE.Location_id
        WHERE TE.Barcode = @TrackingEntity;
    END
    ELSE IF EXISTS (SELECT 1 FROM dbo.CarryingEntity WITH (NOLOCK) WHERE Barcode = @TrackingEntity)
    BEGIN
        SELECT TOP (1) @CarryingEntityID = ID
        FROM dbo.CarryingEntity WITH (NOLOCK)
        WHERE Barcode = @TrackingEntity;
        SELECT TOP (1)
              @TrackingEntity = TE.Barcode
            , @TrackingEntityID = TE.ID
            , @MasterItemID = TE.MasterItem_id
            , @TrackingEntityScannedQty = TE.Qty
            , @ScannedERPLocation = L.ERPLocation
            , @TrackingEntityBatch = TE.Batch
        FROM dbo.TrackingEntity TE WITH (NOLOCK)
        INNER JOIN dbo.Location L WITH (NOLOCK)
            ON L.ID = TE.Location_id
        INNER JOIN dbo.DocumentDetail DD WITH (NOLOCK)
            ON DD.Document_id = @DocumentID
           AND DD.Item_id = TE.MasterItem_id
           AND DD.FromLocation = L.ERPLocation
           AND ISNULL(DD.Cancelled, 0) = 0
           AND (
                    ISNULL(DD.Batch, '') = ''
                    OR ISNULL(TE.Batch, '') = ISNULL(DD.Batch, '')
                )
        WHERE TE.BelongsToEntity_id = @CarryingEntityID
          AND ISNULL(TE.Qty, 0) > 0
        ORDER BY TE.ID;
    END
    ELSE
    BEGIN
        SELECT @valid = 0;
        SELECT @message = CONCAT('Not a valid tracking entity / pallet barcode ', ISNULL(@TrackingEntity, ''));
        GOTO ScriptEnd;
    END;
    IF ISNULL(@TrackingEntityID, 0) = 0
    BEGIN
        SELECT @valid = 0;
        SELECT @message = 'No valid tracking entity found for this barcode.';
        GOTO ScriptEnd;
    END;
    
    
    
    SELECT TOP (1)
          @ERPLocation = DD.FromLocation
        , @DocumentDetailBatch = DD.Batch
    FROM dbo.DocumentDetail DD WITH (NOLOCK)
    WHERE DD.Document_id = @DocumentID
      AND DD.Item_id = @MasterItemID
      AND DD.FromLocation = @ScannedERPLocation
      AND ISNULL(DD.Cancelled, 0) = 0
      AND (
            ISNULL(DD.Batch, '') = ''
            OR ISNULL(DD.Batch, '') = ISNULL(@TrackingEntityBatch, '')
          );
    IF ISNULL(@ERPLocation, '') = ''
    BEGIN
        SELECT @valid = 0;
        SELECT @message = CONCAT(
            'Barcode item/location/batch does not match the document. Barcode: ',
            @TrackingEntity,
            ' | ERP Location: ',
            ISNULL(@ScannedERPLocation, ''),
            ' | Batch: ',
            ISNULL(@TrackingEntityBatch, '')
        );
        GOTO ScriptEnd;
    END;
    IF ISNULL(@DocumentDetailBatch, '') <> ''
       AND ISNULL(@TrackingEntityBatch, '') <> ISNULL(@DocumentDetailBatch, '')
    BEGIN
        SELECT @valid = 0;
        SELECT @message = CONCAT('Incorrect batch scanned. Required batch: ', @DocumentDetailBatch);
        GOTO ScriptEnd;
    END;
    
    
    
    SELECT
          @RequiredQty = SUM(ISNULL(DD.Qty, 0))
        , @AlreadyPickedQty = SUM(ISNULL(DD.ActionQty, 0))
    FROM dbo.DocumentDetail DD WITH (NOLOCK)
    WHERE DD.Document_id = @DocumentID
      AND DD.Item_id = @MasterItemID
      AND DD.FromLocation = @ERPLocation
      AND ISNULL(DD.Cancelled, 0) = 0
      AND (
            ISNULL(@DocumentDetailBatch, '') = ''
            OR ISNULL(DD.Batch, '') = ISNULL(@DocumentDetailBatch, '')
          );
    SET @RequiredQty = ISNULL(@RequiredQty, 0);
    SET @AlreadyPickedQty = ISNULL(@AlreadyPickedQty, 0);
    SET @RemainingQty = @RequiredQty - @AlreadyPickedQty;
    IF @RemainingQty <= 0
    BEGIN
        SELECT @valid = 0;
        SELECT @message = 'This item/location/batch is already fully picked for this document.';
        GOTO ScriptEnd;
    END;
    IF ISNULL(@TrackingEntityScannedQty, 0) <= 0
    BEGIN
        SELECT @valid = 0;
        SELECT @message = CONCAT('Barcode has no available quantity: ', @TrackingEntity);
        GOTO ScriptEnd;
    END;
    SET @QtyOutput =
        CASE
            WHEN @TrackingEntityScannedQty >= @RemainingQty THEN @RemainingQty
            ELSE @TrackingEntityScannedQty
        END;
    
    
    
    SELECT TOP (1) @Location = Barcode
    FROM dbo.Location WITH (NOLOCK)
    WHERE ERPLocation = @ERPLocation
      AND Barcode LIKE '%ORD%'
    ORDER BY Barcode;
    IF ISNULL(@Location, '') = ''
    BEGIN
        SELECT @valid = 0;
        SELECT @message = CONCAT('No ORD location found for ERP location ', ISNULL(@ERPLocation, ''));
        GOTO ScriptEnd;
    END;
    
    
    
    EXEC dbo.Custom_GetRecommendedBarcode
          @MasterItemID = @MasterItemID
        , @ERPLocation = @ERPLocation
        , @RequiredQty = @RemainingQty
        , @DocumentDetailBatch = @DocumentDetailBatch
        , @AdjustedBarcode = NULL
        , @AdjustedQtyToRemove = 0
        , @RecommendedBarcode = @trackingEntityNeedToBeScanned OUTPUT
        , @RecommendedQty = @trackingEntityNeedToBeScannedQty OUTPUT
        , @RecommendedBatch = @TrackingEntityBatch OUTPUT
        , @RecommendedLocationName = @locationName OUTPUT
        , @Instruction = @Instruction OUTPUT
        , @Valid = @RecommendationValid OUTPUT
        , @Message = @RecommendationMessage OUTPUT;
    IF ISNULL(@trackingEntityNeedToBeScanned, '') = ''
    BEGIN
        SELECT @valid = 0;
        SELECT @message = 'No eligible stock found for this item/location/batch.';
        GOTO ScriptEnd;
    END;
    IF @TrackingEntity <> @trackingEntityNeedToBeScanned
    BEGIN
        SELECT @valid = 0;
        SELECT @message = CONCAT(
            'Incorrect barcode scanned. Please scan barcode ',
            @trackingEntityNeedToBeScanned,
            ' for batch ',
            ISNULL(@DocumentDetailBatch, ''),
            ' from location ',
            ISNULL(@locationName, '')
        );
        GOTO ScriptEnd;
    END;
    
    
    
    IF (@RemainingQty - @QtyOutput) <= 0
    BEGIN
        SET @Instruction = 'Item fully processed.';
    END
    ELSE
    BEGIN
        SELECT @RemainingQty = @RemainingQty - @QtyOutput
        EXEC dbo.Custom_GetRecommendedBarcode
              @MasterItemID = @MasterItemID
            , @ERPLocation = @ERPLocation
            , @RequiredQty = @RemainingQty
            , @DocumentDetailBatch = @DocumentDetailBatch
            , @AdjustedBarcode = @TrackingEntity
            , @AdjustedQtyToRemove = @QtyOutput
            , @RecommendedBarcode = @nextTrackingEntity OUTPUT
            , @RecommendedQty = @nextTrackingEntityQty OUTPUT
            , @RecommendedBatch = @TrackingEntityBatch OUTPUT
            , @RecommendedLocationName = @locationName OUTPUT
            , @Instruction = @Instruction OUTPUT
            , @Valid = @RecommendationValid OUTPUT
            , @Message = @RecommendationMessage OUTPUT;
    END;
    UPDATE dbo.DocumentDetail
    SET Instruction = @Instruction
    WHERE Document_id = @DocumentID
      AND Item_id = @MasterItemID
      AND FromLocation = @ERPLocation
      AND ISNULL(Cancelled, 0) = 0
      AND (
            ISNULL(@DocumentDetailBatch, '') = ''
            OR ISNULL(Batch, '') = ISNULL(@DocumentDetailBatch, '')
          );
    SELECT @valid = 1;
    SELECT @message = CONCAT(
        'Pick ',
        CAST(CAST(@QtyOutput AS decimal(19,0)) AS varchar(30)),
        ' of item ',
        (
            SELECT TOP (1) Code
            FROM dbo.MasterItem WITH (NOLOCK)
            WHERE ID = @MasterItemID
        ),
        '. Outstanding qty was ',
        CAST(CAST(@RemainingQty AS decimal(19,0)) AS varchar(30))
    );
    INSERT INTO @Output
    SELECT 'Qty', REPLACE(CAST(@QtyOutput AS varchar(50)), '.', ',');
    INSERT INTO @Output
    SELECT 'Location', @Location;
ScriptEnd:
    INSERT INTO @Output SELECT 'Picker', @user
    INSERT INTO @Output SELECT 'Message', @message;
    INSERT INTO @Output SELECT 'Valid', @valid;
    INSERT INTO @Output SELECT 'StepInput', @stepInput;
    SELECT * FROM @Output;
END
