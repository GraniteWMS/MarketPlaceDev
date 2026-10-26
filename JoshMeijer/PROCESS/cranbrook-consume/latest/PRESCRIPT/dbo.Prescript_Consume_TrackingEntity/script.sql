
CREATE   PROCEDURE [dbo].[Prescript_Consume_TrackingEntity]
(
    @input dbo.ScriptInputParameters READONLY
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE
          @Warehouse varchar(50)
        , @valid bit
        , @message varchar(MAX)
        , @stepInput varchar(MAX)
        , @trackingEntityScanned varchar(50)
        , @trackingEntityScannedQty decimal(19,6)
        , @scannedBatch varchar(50)
        , @scannedExpiryDate datetime
        , @masterItemID bigint
        , @documentName varchar(30)
        , @documentID bigint
        , @DocumentLineNumber varchar(20)
        , @stringLenght int
        , @user varchar(20)
        , @LOCATION varchar(100)
        , @Instruction nvarchar(MAX)
        , @ExcludeBarcode varchar(50)
        , @RequiredQty decimal(19,6)
        , @RecommendedBarcode varchar(50)
        , @RecommendedBatch varchar(50)
        , @RecommendedExpiryDate datetime
        , @RecommendedLocation varchar(100);
    DECLARE @Output TABLE
    (
          [Name] varchar(MAX)
        , [Value] varchar(MAX)
    );
    DECLARE @Recommendations TABLE
    (
          RecommendationRank int
        , Barcode varchar(50)
        , Qty decimal(19,6)
        , Batch varchar(50)
        , ExpiryDate datetime
        , LocationName varchar(100)
        , StatusMessage nvarchar(MAX)
    );
    SELECT @stepInput = [Value]
    FROM @input
    WHERE [Name] = 'StepInput';
    SELECT @user = [Value]
    FROM @input
    WHERE [Name] = 'User';
    SELECT @documentName = [Value]
    FROM @input
    WHERE [Name] = 'Document';
    SET @trackingEntityScanned = @stepInput;
    SET @stringLenght = LEN(@trackingEntityScanned);
    SELECT @documentID = D.ID
    FROM dbo.[Document] D
    WHERE D.[Number] = @documentName;
    SELECT TOP (1)
        @Warehouse = OFV.[Value]
    FROM dbo.OptionalFieldValues_Document OFV WITH (NOLOCK)
    WHERE OFV.BelongsTo_id = @documentID
      AND OFV.OptionalField_Id = 4;
    SET @Warehouse =
        UPPER
        (
            LTRIM
            (
                RTRIM(ISNULL(@Warehouse, 'SAVOURY'))
            )
        );
    SELECT
          @masterItemID = TE.MasterItem_id
        , @trackingEntityScannedQty = TE.Qty
        , @scannedBatch = TE.Batch
        , @scannedExpiryDate = TE.ExpiryDate
        , @LOCATION = L.[Name]
    FROM dbo.TrackingEntity TE
    LEFT JOIN dbo.[Location] L
        ON L.ID = TE.Location_id
    WHERE TE.Barcode = @trackingEntityScanned;
    IF @masterItemID IS NOT NULL
    BEGIN
        SELECT
            @RequiredQty =
                  SUM(ISNULL(DD.Qty, 0))
                - SUM(ISNULL(DD.ActionQty, 0))
        FROM dbo.DocumentDetail DD
        WHERE DD.Document_id = @documentID
          AND DD.Item_id = @masterItemID
          AND ISNULL(DD.Comment, '') <> 'EXSTRA RAW MATERIALS';
        SET @RequiredQty = ISNULL(@RequiredQty, 0);
    END;
    IF @LOCATION LIKE '%INTRANSIT%'
    BEGIN
        SELECT
              @valid = 0
            , @message = 'Barcode is in transit. Please move it out first.';
    END
    ELSE IF @LOCATION IN
    (
          'QUALITY CONTROL'
        , 'R&D LABS - SWEET'
        , 'R&D LABS - SPICE'
        , 'R&D LABS - SAVOURY'
        , 'R&D LABS - CHEM'
        , 'SAVOURY RECEIVING'
        , 'TUNNEY WAREHOUSE RECEIVING'
        , 'SWEET RECEIVING'
    )
    BEGIN
        SELECT
              @valid = 0
            , @message = CONCAT('Cannot scan barcode from ', @LOCATION);
    END
    ELSE
    BEGIN
        IF SUBSTRING(@trackingEntityScanned, 1, 1) = 'p'
        BEGIN
            SET @DocumentLineNumber =
                SUBSTRING
                (
                      @trackingEntityScanned
                    , 2
                    , @stringLenght
                );
            IF EXISTS
            (
                SELECT 1
                FROM dbo.DocumentDetail DD
                WHERE DD.Document_id = @documentID
                  AND DD.LineNumber = @DocumentLineNumber
            )
            BEGIN
                SELECT TOP (1)
                    @masterItemID = DD.Item_id
                FROM dbo.DocumentDetail DD
                WHERE DD.Document_id = @documentID
                  AND DD.LineNumber = @DocumentLineNumber;
                SELECT
                    @RequiredQty =
                          SUM(ISNULL(DD.Qty, 0))
                        - SUM(ISNULL(DD.ActionQty, 0))
                FROM dbo.DocumentDetail DD
                WHERE DD.Document_id = @documentID
                  AND DD.Item_id = @masterItemID
                  AND ISNULL(DD.Comment, '') <> 'EXSTRA RAW MATERIALS';
                SET @RequiredQty = ISNULL(@RequiredQty, 0);
                INSERT INTO @Recommendations
                (
                      RecommendationRank
                    , Barcode
                    , Qty
                    , Batch
                    , ExpiryDate
                    , LocationName
                    , StatusMessage
                )
                EXEC dbo.usp_Picking_GetRecommendedBarcodes
                      @MasterItemID = @masterItemID
                    , @RequiredQty = @RequiredQty
                    , @Warehouse = @Warehouse
                    , @ExcludeBarcode = NULL
                    , @TopCount = 1;
                SELECT TOP (1)
                    @Instruction =
                        CASE
                            WHEN R.Barcode IS NOT NULL
                                THEN CONCAT
                                (
                                      'Pick Barcode: '
                                    , R.Barcode
                                    , ' | BN: '
                                    , UPPER(ISNULL(R.Batch, ''))
                                    , ' | Loc: '
                                    , ISNULL(R.LocationName, '')
                                )
                            ELSE ISNULL
                                 (
                                     R.StatusMessage,
                                     'No STOCK available!'
                                 )
                        END
                FROM @Recommendations R
                ORDER BY R.RecommendationRank;
                SELECT
                      @valid = 0
                    , @message = @Instruction;
            END
            ELSE
            BEGIN
                SELECT
                      @valid = 0
                    , @message = 'Not a VALID line number';
            END;
        END
        ELSE
        BEGIN
            IF @masterItemID IS NULL
            BEGIN
                SELECT
                      @valid = 0
                    , @message = 'Barcode does not exist';
            END
            ELSE
            BEGIN
                INSERT INTO @Recommendations
                (
                      RecommendationRank
                    , Barcode
                    , Qty
                    , Batch
                    , ExpiryDate
                    , LocationName
                    , StatusMessage
                )
                EXEC dbo.usp_Picking_GetRecommendedBarcodes
                      @MasterItemID = @masterItemID
                    , @RequiredQty = @RequiredQty
                    , @Warehouse = @Warehouse
                    , @ExcludeBarcode = NULL
                    , @TopCount = 1;
                SELECT TOP (1)
                      @RecommendedBarcode = R.Barcode
                    , @RecommendedBatch = R.Batch
                    , @RecommendedExpiryDate = R.ExpiryDate
                    , @RecommendedLocation = R.LocationName
                FROM @Recommendations R
                WHERE R.Barcode IS NOT NULL
                ORDER BY R.RecommendationRank;
                IF
                (
                       @trackingEntityScanned = @RecommendedBarcode
                    OR
                    (
                        ISNULL(LTRIM(RTRIM(@RecommendedBatch)), '') <> ''
                        AND ISNULL(LTRIM(RTRIM(@scannedBatch)), '') <> ''
                        AND UPPER(LTRIM(RTRIM(@scannedBatch)))
                            = UPPER(LTRIM(RTRIM(@RecommendedBatch)))
                    )
                    OR
                    (
                        @RecommendedExpiryDate IS NOT NULL
                        AND @scannedExpiryDate IS NOT NULL
                        AND CONVERT(date, @scannedExpiryDate)
                            = CONVERT(date, @RecommendedExpiryDate)
                    )
                )
                BEGIN
                    SELECT
                          @valid = 1
                        , @message = '';
                    SET @ExcludeBarcode =
                        CASE
                            WHEN ISNULL(@trackingEntityScannedQty, 0) > 1
                                THEN NULL
                            ELSE @trackingEntityScanned
                        END;
                    DELETE FROM @Recommendations;
                    INSERT INTO @Recommendations
                    (
                          RecommendationRank
                        , Barcode
                        , Qty
                        , Batch
                        , ExpiryDate
                        , LocationName
                        , StatusMessage
                    )
                    EXEC dbo.usp_Picking_GetRecommendedBarcodes
                          @MasterItemID = @masterItemID
                        , @RequiredQty = @RequiredQty
                        , @Warehouse = @Warehouse
                        , @ExcludeBarcode = @ExcludeBarcode
                        , @TopCount = 1;
                    SET @Instruction = NULL;
                    SELECT TOP (1)
                        @Instruction =
                            CASE
                                WHEN R.Barcode IS NOT NULL
                                    THEN CONCAT
                                    (
                                          'Pick Barcode: '
                                        , R.Barcode
                                        , ' | BN: '
                                        , UPPER(ISNULL(R.Batch, ''))
                                        , ' | Loc: '
                                        , ISNULL(R.LocationName, '')
                                    )
                                ELSE ISNULL
                                     (
                                         R.StatusMessage,
                                         'No STOCK available!'
                                     )
                            END
                    FROM @Recommendations R
                    ORDER BY R.RecommendationRank;
                    UPDATE dbo.DocumentDetail
                    SET
                          Comment = ''
                        , Instruction = @Instruction
                    WHERE Document_id = @documentID
                      AND Item_id = @masterItemID
                      AND [Type] = 'INPUT';
                END
                ELSE IF @user IN
                (
                      '070'
                    , 'NKAGE'
                    , 'NKAGER'
                    , 'CONOR'
                    , 'SEAN'
                    , 'KEAMO'
                    , 'SBONISO'
                    , 'KHUTSO'
                    , 'POLLEN'
                    , 'JABU'
                    , 'KARABO'
                    , 'KARELM'
                    , 'KAREL'
                    , 'PETER'
                    , 'THOKOZANI'
                    , 'MALUSI'
                    , 'MUZI'
                )
                BEGIN
                    SELECT
                          @valid = 1
                        , @message = '';
                END
                ELSE
                BEGIN
                    SELECT
                          @valid = 0
                        , @message =
                            'Please scan the recommended barcode, or another barcode with the same batch or expiry date, or ask a supervisor to override it.';
                END;
            END;
        END;
    END;
    IF @valid = 1
    BEGIN
        ;WITH UserTotals AS
        (
            SELECT
                  D.[Number]
                , U.[Name]
                , SUM(CAST(T.ActionQty AS decimal(19,6))) AS TotalPicked
                , MAX
                  (
                      CAST(T.DocumentDetailQty AS decimal(19,6))
                  ) AS DocumentQty
            FROM dbo.[Transaction] T
            INNER JOIN dbo.[Users] U
                ON T.User_id = U.ID
            INNER JOIN dbo.[Document] D
                ON T.Document_id = D.ID
            WHERE T.Document_id = @documentID
              AND T.FromMasterItem_id = @masterItemID
              AND T.ReversalTransaction_id = 0
              AND T.Process = 'CONSUME'
            GROUP BY
                  D.[Number]
                , U.[Name]
        )
        SELECT
            @message =
                CASE
                    WHEN SUM(UT.TotalPicked) = 0
                        THEN ''
                    ELSE CONCAT
                    (
                          STRING_AGG
                          (
                              CONCAT
                              (
                                    UT.[Name]
                                  , ' scanned '
                                  , FORMAT(UT.TotalPicked, 'N6')
                              ),
                              ', '
                          )
                        , ' — Total scanned: '
                        , FORMAT(SUM(UT.TotalPicked), 'N6')
                        , ' | Required: '
                        , FORMAT(MAX(UT.DocumentQty), 'N6')
                        , ' | Outstanding: '
                        , FORMAT
                          (
                              CASE
                                  WHEN MAX(UT.DocumentQty)
                                       - SUM(UT.TotalPicked) < 0
                                      THEN 0
                                  ELSE MAX(UT.DocumentQty)
                                       - SUM(UT.TotalPicked)
                              END,
                              'N6'
                          )
                    )
                END
        FROM UserTotals UT
        GROUP BY UT.[Number];
    END;
    INSERT INTO @Output
    SELECT 'Message', ISNULL(@message, '');
    INSERT INTO @Output
    SELECT 'Valid', ISNULL(CONVERT(varchar(10), @valid), '0');
    INSERT INTO @Output
    SELECT 'StepInput', @stepInput;
    SELECT [Name], [Value]
    FROM @Output;
END;
