
CREATE   PROCEDURE [dbo].[Custom_AssignDocumentDetailPicker_ByRecommendedWarehouse]
(
      @DocumentID BIGINT
    , @UserName VARCHAR(100)
    , @PickerLocation VARCHAR(100)
    , @LinesToAssign INT = 5
    , @AssignedCount INT OUTPUT
    , @Message VARCHAR(MAX) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @AssignedCount = 0;
    SET @Message = '';
    DECLARE @OptionalFieldID BIGINT;
    SELECT TOP (1) @OptionalFieldID = ID
    FROM dbo.OptionalFields WITH (NOLOCK)
    WHERE [Name] = 'DocumentDetailPicker';
    IF ISNULL(@OptionalFieldID, 0) = 0
    BEGIN
        SET @Message = 'Optional field DocumentDetailPicker does not exist.';
        RETURN;
    END;
    IF ISNULL(@PickerLocation, '') = ''
    BEGIN
        SET @Message = 'PickerLocation was not supplied.';
        RETURN;
    END;
    IF ISNULL(@LinesToAssign, 0) <= 0
    BEGIN
        SET @LinesToAssign = 5;
    END;
    
    
    
    IF EXISTS
    (
        SELECT 1
        FROM dbo.DocumentDetail DD WITH (NOLOCK)
        INNER JOIN dbo.OptionalFieldValues_DocumentDetail OFV WITH (NOLOCK)
            ON OFV.BelongsTo_id = DD.ID
           AND OFV.OptionalField_id = @OptionalFieldID
           AND ISNULL(OFV.[Value], '') = @UserName
        WHERE DD.Document_id = @DocumentID
          AND ISNULL(DD.Cancelled, 0) = 0
          AND ISNULL(DD.Completed, 0) = 0
          AND ISNULL(DD.ActionQty, 0) < ISNULL(DD.Qty, 0)
    )
    BEGIN
        SELECT @AssignedCount = COUNT(1)
        FROM dbo.DocumentDetail DD WITH (NOLOCK)
        INNER JOIN dbo.OptionalFieldValues_DocumentDetail OFV WITH (NOLOCK)
            ON OFV.BelongsTo_id = DD.ID
           AND OFV.OptionalField_id = @OptionalFieldID
           AND ISNULL(OFV.[Value], '') = @UserName
        WHERE DD.Document_id = @DocumentID
          AND ISNULL(DD.Cancelled, 0) = 0
          AND ISNULL(DD.Completed, 0) = 0
          AND ISNULL(DD.ActionQty, 0) < ISNULL(DD.Qty, 0);
        SET @Message = CONCAT('Picker still has ', @AssignedCount, ' assigned line(s) to complete.');
        RETURN;
    END;
    IF OBJECT_ID('tempdb..#CandidateLines') IS NOT NULL
        DROP TABLE #CandidateLines;
    CREATE TABLE #CandidateLines
    (
          RowID BIGINT IDENTITY(1,1) PRIMARY KEY
        , DocumentDetailID BIGINT NOT NULL
        , LineNumber INT NULL
        , MasterItemID BIGINT NOT NULL
        , ERPLocation VARCHAR(30) NOT NULL
        , DocumentDetailBatch VARCHAR(50) NULL
        , RequiredQty DECIMAL(19,4) NOT NULL
        , RecommendedBarcode VARCHAR(50) NULL
        , RecommendedQty DECIMAL(19,4) NULL
        , RecommendedBatch VARCHAR(50) NULL
        , RecommendedLocationName VARCHAR(50) NULL
        , RecommendedWarehouseType VARCHAR(100) NULL
        , RecommendationInstruction NVARCHAR(MAX) NULL
    );
    INSERT INTO #CandidateLines
    (
          DocumentDetailID
        , LineNumber
        , MasterItemID
        , ERPLocation
        , DocumentDetailBatch
        , RequiredQty
    )
    SELECT
          DD.ID
        , DD.LineNumber
        , DD.Item_id
        , DD.FromLocation
        , DD.Batch
        , CAST(ISNULL(DD.Qty, 0) - ISNULL(DD.ActionQty, 0) AS DECIMAL(19,4))
    FROM dbo.DocumentDetail DD WITH (NOLOCK)
    LEFT JOIN dbo.OptionalFieldValues_DocumentDetail OFV WITH (NOLOCK)
        ON OFV.BelongsTo_id = DD.ID
       AND OFV.OptionalField_id = @OptionalFieldID
    WHERE DD.Document_id = @DocumentID
      AND ISNULL(DD.Cancelled, 0) = 0
      AND ISNULL(DD.Completed, 0) = 0
      AND ISNULL(DD.ActionQty, 0) < ISNULL(DD.Qty, 0)
      AND ISNULL(OFV.[Value], '') = ''
    ORDER BY DD.LineNumber, DD.ID;
    IF NOT EXISTS (SELECT 1 FROM #CandidateLines)
    BEGIN
        SET @Message = 'No available unassigned lines found for this document.';
        RETURN;
    END;
    
    
    
    
    DECLARE
          @RowID BIGINT
        , @MasterItemID BIGINT
        , @ERPLocation VARCHAR(30)
        , @DocumentDetailBatch VARCHAR(50)
        , @RequiredQty DECIMAL(19,4)
        , @RecommendedBarcode VARCHAR(50)
        , @RecommendedQty DECIMAL(19,4)
        , @RecommendedBatch VARCHAR(50)
        , @RecommendedLocationName VARCHAR(50)
        , @Instruction NVARCHAR(MAX)
        , @RecommendationValid BIT
        , @RecommendationMessage VARCHAR(MAX)
        , @RecommendedWarehouseType VARCHAR(100);
    DECLARE AssignCursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT
              RowID
            , MasterItemID
            , ERPLocation
            , DocumentDetailBatch
            , RequiredQty
        FROM #CandidateLines
        ORDER BY LineNumber, DocumentDetailID;
    OPEN AssignCursor;
    FETCH NEXT FROM AssignCursor
    INTO @RowID, @MasterItemID, @ERPLocation, @DocumentDetailBatch, @RequiredQty;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @RecommendedBarcode = '';
        SET @RecommendedQty = 0;
        SET @RecommendedBatch = '';
        SET @RecommendedLocationName = '';
        SET @Instruction = '';
        SET @RecommendationValid = 1;
        SET @RecommendationMessage = '';
        SET @RecommendedWarehouseType = '';
        EXEC dbo.Custom_GetRecommendedBarcode
              @MasterItemID = @MasterItemID
            , @ERPLocation = @ERPLocation
            , @RequiredQty = @RequiredQty
            , @DocumentDetailBatch = @DocumentDetailBatch
            , @AdjustedBarcode = NULL
            , @AdjustedQtyToRemove = 0
            , @RecommendedBarcode = @RecommendedBarcode OUTPUT
            , @RecommendedQty = @RecommendedQty OUTPUT
            , @RecommendedBatch = @RecommendedBatch OUTPUT
            , @RecommendedLocationName = @RecommendedLocationName OUTPUT
            , @Instruction = @Instruction OUTPUT
            , @Valid = @RecommendationValid OUTPUT
            , @Message = @RecommendationMessage OUTPUT;
        IF ISNULL(@RecommendedBarcode, '') <> ''
        BEGIN
            SELECT TOP (1)
                @RecommendedWarehouseType = L.[Type]
            FROM dbo.TrackingEntity TE WITH (NOLOCK)
            INNER JOIN dbo.Location L WITH (NOLOCK)
                ON L.ID = TE.Location_id
            WHERE TE.Barcode = @RecommendedBarcode;
        END;
        UPDATE #CandidateLines
        SET
              RecommendedBarcode = @RecommendedBarcode
            , RecommendedQty = @RecommendedQty
            , RecommendedBatch = @RecommendedBatch
            , RecommendedLocationName = @RecommendedLocationName
            , RecommendedWarehouseType = @RecommendedWarehouseType
            , RecommendationInstruction = @Instruction
        WHERE RowID = @RowID;
        FETCH NEXT FROM AssignCursor
        INTO @RowID, @MasterItemID, @ERPLocation, @DocumentDetailBatch, @RequiredQty;
    END;
    CLOSE AssignCursor;
    DEALLOCATE AssignCursor;
    
    
    
    
    
    DECLARE @Lines TABLE
    (
        DocumentDetailID BIGINT PRIMARY KEY
    );
    INSERT INTO @Lines
    (
        DocumentDetailID
    )
    SELECT TOP (@LinesToAssign)
        DocumentDetailID
    FROM #CandidateLines
    WHERE ISNULL(RecommendedBarcode, '') <> ''
      AND ISNULL(RecommendedWarehouseType, '') = @PickerLocation
    ORDER BY MasterItemID;
    IF NOT EXISTS (SELECT 1 FROM @Lines)
    BEGIN
        SET @Message = CONCAT(
            'No assignable lines found for picker ',
            ISNULL(@UserName, ''),
            ' in warehouse ',
            ISNULL(@PickerLocation, ''),
            '. Lines without a recommended barcode were not assigned.'
        );
        RETURN;
    END;
    MERGE dbo.OptionalFieldValues_DocumentDetail AS T
    USING @Lines AS S
        ON T.BelongsTo_id = S.DocumentDetailID
       AND T.OptionalField_id = @OptionalFieldID
    WHEN MATCHED THEN
        UPDATE SET [Value] = @UserName
    WHEN NOT MATCHED THEN
        INSERT
        (
              BelongsTo_id
            , OptionalField_id
            , [Value]
        )
        VALUES
        (
              S.DocumentDetailID
            , @OptionalFieldID
            , @UserName
        );
    SELECT @AssignedCount = COUNT(1)
    FROM @Lines;
    SET @Message = CONCAT(
        'Assigned ',
        @AssignedCount,
        ' line(s) to picker ',
        @UserName,
        ' for warehouse ',
        @PickerLocation,
        '.'
    );
END
