
CREATE   PROCEDURE [dbo].[PreScript_Consume_Qty]
(
    @input dbo.ScriptInputParameters READONLY
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE
          @Warehouse varchar(50)
        , @valid bit = 1
        , @message varchar(MAX) = ''
        , @stepInput varchar(MAX)
        , @User varchar(50)
        , @DocNumber varchar(50)
        , @DocumentID bigint
        , @ScannedBarcode varchar(50)
        , @ScannedMIID bigint
        , @ScannedMICode varchar(100)
        , @ScannedLocation varchar(100)
        , @ScannedBatch varchar(50)
        , @ScannedExpiry datetime
        , @ScannedQty decimal(19,6)
        , @NeededBarcode varchar(50)
        , @NeededMICode varchar(100)
        , @NeededLocation varchar(100)
        , @NeededBatch varchar(50)
        , @NeededExpiry datetime
        , @NeededQty decimal(19,6)
        , @RequiredQty decimal(19,6)
        , @MatchResult varchar(20);
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
    SELECT @User = [Value]
    FROM @input
    WHERE [Name] = 'User';
    SELECT @DocNumber = [Value]
    FROM @input
    WHERE [Name] = 'Document';
    SELECT @DocumentID = D.ID
    FROM dbo.[Document] D WITH (NOLOCK)
    WHERE D.[Number] = @DocNumber;
    SELECT @ScannedBarcode = [Value]
    FROM @input
    WHERE [Name] = 'TrackingEntity';
    SELECT
          @ScannedMIID = TE.MasterItem_id
        , @ScannedQty = TE.Qty
        , @ScannedBatch = TE.Batch
        , @ScannedExpiry = TE.ExpiryDate
        , @ScannedLocation = L.[Name]
        , @ScannedMICode = MI.[Code]
    FROM dbo.TrackingEntity TE WITH (NOLOCK)
    LEFT JOIN dbo.[Location] L WITH (NOLOCK)
        ON L.ID = TE.Location_id
    LEFT JOIN dbo.MasterItem MI WITH (NOLOCK)
        ON MI.ID = TE.MasterItem_id
    WHERE TE.Barcode = @ScannedBarcode;
    SELECT
        @RequiredQty =
              SUM(ISNULL(DD.Qty, 0))
            - SUM(ISNULL(DD.ActionQty, 0))
    FROM dbo.DocumentDetail DD
    WHERE DD.Document_id = @DocumentID
      AND DD.Item_id = @ScannedMIID
      AND ISNULL(DD.Comment, '') <> 'EXSTRA RAW MATERIALS';
    SET @RequiredQty = ISNULL(@RequiredQty, 0);
    IF @ScannedMIID IS NOT NULL
    BEGIN
        SELECT TOP (1)
            @Warehouse = OFV.[Value]
        FROM dbo.OptionalFieldValues_Document OFV WITH (NOLOCK)
        WHERE OFV.BelongsTo_id = @DocumentID
          AND OFV.OptionalField_Id = 4;
        SET @Warehouse =
            UPPER
            (
                LTRIM
                (
                    RTRIM(ISNULL(@Warehouse, 'SAVOURY'))
                )
            );
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
              @MasterItemID = @ScannedMIID
            , @RequiredQty = @RequiredQty
            , @Warehouse = @Warehouse
            , @ExcludeBarcode = NULL
            , @TopCount = 1;
        SELECT TOP (1)
              @NeededBarcode = R.Barcode
            , @NeededQty = R.Qty
            , @NeededBatch = R.Batch
            , @NeededExpiry = R.ExpiryDate
            , @NeededLocation = R.LocationName
        FROM @Recommendations R
        WHERE R.Barcode IS NOT NULL
        ORDER BY R.RecommendationRank;
        SELECT @NeededMICode = MI.Code
        FROM dbo.MasterItem MI
        WHERE MI.ID = @ScannedMIID;
        SET @MatchResult =
            CASE
                WHEN @NeededBarcode IS NULL
                    THEN 'MISMATCH'
                WHEN @ScannedBarcode = @NeededBarcode
                    THEN 'MATCH'
                WHEN ISNULL(LTRIM(RTRIM(@NeededBatch)), '') <> ''
                 AND ISNULL(LTRIM(RTRIM(@ScannedBatch)), '') <> ''
                 AND UPPER(LTRIM(RTRIM(@ScannedBatch)))
                     = UPPER(LTRIM(RTRIM(@NeededBatch)))
                    THEN 'MATCH'
                WHEN @NeededExpiry IS NOT NULL
                 AND @ScannedExpiry IS NOT NULL
                 AND CONVERT(date, @ScannedExpiry)
                     = CONVERT(date, @NeededExpiry)
                    THEN 'MATCH'
                ELSE 'MISMATCH'
            END;
    END
    ELSE
    BEGIN
        SET @MatchResult = 'MISMATCH';
    END;
    INSERT INTO dbo.Custom_ScanComparisonLog
    (
          UserName
        , ScanDate
        , DocumentName
        , DocumentID
        , ScannedBarcode
        , NeededBarcode
        , ScannedItem
        , NeededItem
        , ScannedLocation
        , NeededLocation
        , ScannedBatch
        , NeededBatch
        , ScannedExpiryDate
        , NeededExpiryDate
        , ScannedQty
        , NeededQty
        , MatchResult
    )
    VALUES
    (
          @User
        , GETDATE()
        , @DocNumber
        , @DocumentID
        , @ScannedBarcode
        , @NeededBarcode
        , @ScannedMICode
        , @NeededMICode
        , @ScannedLocation
        , @NeededLocation
        , @ScannedBatch
        , @NeededBatch
        , @ScannedExpiry
        , @NeededExpiry
        , @ScannedQty
        , @NeededQty
        , @MatchResult
    );
    SET @stepInput = REPLACE(@stepInput, '.', ',');
    INSERT INTO @Output
    SELECT 'Qty', @stepInput;
    SELECT
          @valid = 1
        , @message = 'WELL DONE';
    INSERT INTO @Output SELECT 'Message', @message;
    INSERT INTO @Output SELECT 'Valid', @valid;
    INSERT INTO @Output SELECT 'StepInput', @stepInput;
    SELECT [Name], [Value]
    FROM @Output;
END;
