
CREATE   PROCEDURE dbo.Custom_GetRecommendedBarcode
(
      @MasterItemID              BIGINT
    , @ERPLocation               VARCHAR(30)
    , @RequiredQty               DECIMAL(19,4)
    , @DocumentDetailBatch       VARCHAR(50) = NULL
    , @AdjustedBarcode           VARCHAR(50) = NULL
    , @AdjustedQtyToRemove       DECIMAL(19,4) = 0
    , @RecommendedBarcode        VARCHAR(50) OUTPUT
    , @RecommendedQty            DECIMAL(19,4) OUTPUT
    , @RecommendedBatch          VARCHAR(50) OUTPUT
    , @RecommendedLocationName   VARCHAR(50) OUTPUT
    , @Instruction               NVARCHAR(MAX) OUTPUT
    , @Valid                     BIT OUTPUT
    , @Message                   VARCHAR(MAX) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @RecommendedBarcode = '';
    SET @RecommendedQty = 0;
    SET @RecommendedBatch = '';
    SET @RecommendedLocationName = '';
    SET @Instruction = '';
    SET @Valid = 1;
    SET @Message = '';
    DECLARE @PickingOptionalFieldID BIGINT;
    DECLARE @ExpiryDateExtendedOptionalFieldID BIGINT;
    SELECT TOP (1) @PickingOptionalFieldID = ID
    FROM dbo.OptionalFields WITH (NOLOCK)
    WHERE UPPER([Name]) = 'PICKING';
    SELECT TOP (1) @ExpiryDateExtendedOptionalFieldID = ID
    FROM dbo.OptionalFields WITH (NOLOCK)
    WHERE [Name] = 'ExpiryDateExtended';
    IF ISNULL(@MasterItemID, 0) = 0
    BEGIN
        SET @Valid = 0;
        SET @Message = 'Master item was not supplied.';
        RETURN;
    END
    IF ISNULL(@ERPLocation, '') = ''
    BEGIN
        SET @Valid = 0;
        SET @Message = 'ERP location was not supplied.';
        RETURN;
    END
    IF ISNULL(@RequiredQty, 0) <= 0
    BEGIN
        SET @Instruction = 'Item fully processed.';
        RETURN;
    END
    ;WITH Eligible AS
    (
        SELECT
              TE.Barcode
            , TE.Batch
            , TE.CreatedDate
            , TE.ExpiryDate
            , CAST(
                CASE
                    WHEN ISNULL(@AdjustedBarcode, '') <> ''
                     AND TE.Barcode = @AdjustedBarcode
                    THEN TE.Qty - ISNULL(@AdjustedQtyToRemove, 0)
                    ELSE TE.Qty
                END AS DECIMAL(19,4)
              ) AS Qty
            , L.[Name] AS LocationName
            , UPPER(ISNULL(OFVTE.[Value], 'NO')) AS ExpiryExtended
        FROM dbo.TrackingEntity TE WITH (NOLOCK)
        INNER JOIN dbo.[Location] L WITH (NOLOCK)
            ON L.ID = TE.Location_id
        LEFT JOIN dbo.OptionalFieldValues_TrackingEntity OFVTE WITH (NOLOCK)
            ON OFVTE.BelongsTo_id = TE.ID
           AND OFVTE.OptionalField_id = @ExpiryDateExtendedOptionalFieldID
        WHERE TE.MasterItem_id = @MasterItemID
          AND L.ERPLocation = @ERPLocation
          AND TE.Qty <> 0
          AND ISNULL(TE.OnHold, 0) <> 1
          AND TE.InStock = 1
          AND (
                ISNULL(@DocumentDetailBatch, '') = ''
                OR ISNULL(TE.Batch, '') = ISNULL(@DocumentDetailBatch, '')
              )
          AND EXISTS
          (
              SELECT 1
              FROM dbo.OptionalFieldValues_Location OFVL WITH (NOLOCK)
              WHERE OFVL.BelongsTo_id = L.ID
                AND OFVL.OptionalField_id = @PickingOptionalFieldID
                AND UPPER(ISNULL(OFVL.[Value], 'NO')) = 'YES'
          )
          AND (TE.ExpiryDate IS NULL OR CONVERT(DATE, TE.ExpiryDate) >= CONVERT(DATE, GETDATE()))
    ),
    EligibleRanked AS
    (
        SELECT
              Barcode
            , Batch
            , CreatedDate
            , ExpiryDate
            , Qty
            , LocationName
            , ExpiryExtended
            , CAST(CASE WHEN Qty >= @RequiredQty THEN 1 ELSE 0 END AS BIT) AS CanFulfillOrder
            , CASE
                  WHEN Qty >= 900 THEN 1
                  WHEN Qty >= @RequiredQty THEN 2
                  WHEN Qty >= (@RequiredQty * 0.5) THEN 3
                  ELSE 4
              END AS SizeRank
        FROM Eligible
        WHERE Qty > 0
    ),
    NormalPick AS
    (
        SELECT TOP (1) *
        FROM EligibleRanked
        WHERE ExpiryExtended <> 'YES'
        ORDER BY
              CanFulfillOrder DESC
            , SizeRank ASC
            , Qty DESC
            , CASE WHEN ExpiryDate IS NULL THEN 1 ELSE 0 END
            , ExpiryDate
            , CreatedDate
    ),
    ExtendedPick AS
    (
        SELECT TOP (1) *
        FROM EligibleRanked
        WHERE ExpiryExtended = 'YES'
        ORDER BY
              CanFulfillOrder DESC
            , SizeRank ASC
            , Qty DESC
            , CASE WHEN ExpiryDate IS NULL THEN 1 ELSE 0 END
            , ExpiryDate
            , CreatedDate
    ),
    Recommended AS
    (
        SELECT EP.*
        FROM ExtendedPick EP
        CROSS JOIN NormalPick NP
        WHERE EP.CreatedDate < NP.CreatedDate
        UNION ALL
        SELECT NP.*
        FROM NormalPick NP
        UNION ALL
        SELECT EP.*
        FROM ExtendedPick EP
        WHERE NOT EXISTS (SELECT 1 FROM NormalPick)
    )
    SELECT TOP (1)
          @RecommendedBarcode = X.Barcode
        , @RecommendedQty = X.Qty
        , @RecommendedBatch = X.Batch
        , @RecommendedLocationName = X.LocationName
    FROM Recommended X
    ORDER BY
          CASE
              WHEN X.ExpiryExtended = 'YES'
                   AND EXISTS (SELECT 1 FROM NormalPick)
                   AND X.CreatedDate < (SELECT TOP (1) CreatedDate FROM NormalPick)
              THEN 0
              ELSE 1
            END
        , X.CanFulfillOrder DESC
        , X.SizeRank ASC
        , X.Qty DESC
        , CASE WHEN X.ExpiryDate IS NULL THEN 1 ELSE 0 END
        , X.ExpiryDate
        , X.CreatedDate;
    IF ISNULL(@RecommendedBarcode, '') = ''
    BEGIN
        SET @Instruction = CONCAT(
            'No available stock found for item ',
            ISNULL((SELECT TOP (1) Code FROM dbo.MasterItem WITH (NOLOCK) WHERE ID = @MasterItemID), ''),
            CASE
                WHEN ISNULL(@DocumentDetailBatch, '') <> ''
                THEN CONCAT(' and batch ', @DocumentDetailBatch)
                ELSE ''
            END,
            ' in ERP location ',
            ISNULL(@ERPLocation, ''),
            '.'
        );
    END
    ELSE
    BEGIN
        SET @Instruction = CONCAT(
            'Pick Barcode: ', @RecommendedBarcode,
            ' | BN: ', UPPER(ISNULL(@RecommendedBatch, '')),
            ' | Loc : ', @RecommendedLocationName
        );
    END
END
