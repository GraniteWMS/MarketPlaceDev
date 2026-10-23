
CREATE   PROCEDURE [dbo].[PrescriptTransferDocument]
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
    DECLARE @valid bit;
    DECLARE @message varchar(MAX);
    DECLARE @stepInput varchar(MAX);
    SELECT @stepInput = Value
    FROM @input
    WHERE Name = 'StepInput';
    DECLARE @Document varchar(50) = @stepInput;
    DECLARE @DocumentID bigint;
    DECLARE @ERPLocation varchar(30);
    DECLARE @RequiredQty decimal(19,4);
    DECLARE @DocumentDetailBatch varchar(50);
    IF EXISTS (SELECT 1 FROM dbo.Document WITH (NOLOCK) WHERE Number = @Document AND [Type] = 'TRANSFER')
    BEGIN
        SELECT @stepInput = @Document;
    END
    ELSE 
    BEGIN
        SELECT @stepInput = CONCAT('TRF', @Document);
    END;
    IF EXISTS (SELECT 1 FROM dbo.Document WITH (NOLOCK) WHERE Number = @stepInput AND [Type] = 'TRANSFER')
    BEGIN
        DECLARE @documentLines int;
        DECLARE @counter int = 1;
        DECLARE @masterItemID bigint;
        DECLARE @trackingEntity varchar(50);
        DECLARE @trackingEntityQty decimal(19,4);
        DECLARE @TrackingEntityBatch varchar(50);
        DECLARE @locationName varchar(50);
        DECLARE @DocumentStatus varchar(30);
        DECLARE @Instruction nvarchar(max);
        DECLARE @RecommendationValid bit;
        DECLARE @RecommendationMessage varchar(max);
        SELECT
              @DocumentID = ID
            , @DocumentStatus = [Status]
        FROM dbo.Document WITH (NOLOCK)
        WHERE Number = @stepInput;
        IF @DocumentStatus NOT IN ('CANCELED', 'CANCELLED')
        BEGIN
            IF OBJECT_ID('tempdb..#tempTable') IS NOT NULL
                DROP TABLE #tempTable;
            CREATE TABLE #tempTable
            (
                ID bigint IDENTITY(1,1),
                MASTERITEM_ID bigint NOT NULL,
                ERPLocation varchar(30) NOT NULL,
                DocumentDetailBatch varchar(50) NULL,
                RequiredQty decimal(19,4)
            );
            INSERT INTO #tempTable
            (
                MASTERITEM_ID,
                ERPLocation,
                DocumentDetailBatch,
                RequiredQty
            )
            SELECT
                  Item_Id
                , FromLocation
                , Batch
                , SUM(ISNULL(Qty, 0))
            FROM dbo.DocumentDetail WITH (NOLOCK)
            WHERE Document_id = @DocumentID
              AND ISNULL(Cancelled, 0) = 0
            GROUP BY
                  Item_Id
                , FromLocation
                , Batch;
            SELECT @documentLines = COUNT(*)
            FROM #tempTable;
            WHILE (@counter <= @documentLines)
            BEGIN
                SELECT
                      @masterItemID = MASTERITEM_ID
                    , @ERPLocation = ERPLocation
                    , @DocumentDetailBatch = DocumentDetailBatch
                    , @RequiredQty = RequiredQty
                FROM #tempTable
                WHERE ID = @counter;
                SET @trackingEntity = '';
                SET @trackingEntityQty = 0;
                SET @TrackingEntityBatch = '';
                SET @locationName = '';
                SET @Instruction = '';
                SET @RecommendationValid = 1;
                SET @RecommendationMessage = '';
                EXEC dbo.Custom_GetRecommendedBarcode
                      @MasterItemID = @masterItemID
                    , @ERPLocation = @ERPLocation
                    , @RequiredQty = @RequiredQty
                    , @DocumentDetailBatch = @DocumentDetailBatch
                    , @AdjustedBarcode = NULL
                    , @AdjustedQtyToRemove = 0
                    , @RecommendedBarcode = @trackingEntity OUTPUT
                    , @RecommendedQty = @trackingEntityQty OUTPUT
                    , @RecommendedBatch = @TrackingEntityBatch OUTPUT
                    , @RecommendedLocationName = @locationName OUTPUT
                    , @Instruction = @Instruction OUTPUT
                    , @Valid = @RecommendationValid OUTPUT
                    , @Message = @RecommendationMessage OUTPUT;
                UPDATE dbo.DocumentDetail
                SET Instruction = @Instruction
                WHERE Document_id = @DocumentID
                  AND Item_id = @masterItemID
                  AND FromLocation = @ERPLocation
                  AND ISNULL(Cancelled, 0) = 0
                  AND (
                        ISNULL(@DocumentDetailBatch, '') = ''
                        OR ISNULL(Batch, '') = ISNULL(@DocumentDetailBatch, '')
                      );
                SELECT @counter = @counter + 1;
            END;
            SELECT @message = '';
            SELECT @valid = 1;
            DROP TABLE #tempTable;
        END
        ELSE
        BEGIN
            SELECT @valid = 0;
            SELECT @message = CONCAT('Document ', @stepInput, ' has been CANCELED');
        END;
    END
    ELSE
    BEGIN
        SELECT @valid = 0;
        SELECT @message = CONCAT(@Document, ' is not a valid TRANSFER document');
    END;
    INSERT INTO @Output SELECT 'Message', @message;
    INSERT INTO @Output SELECT 'Valid', @valid;
    INSERT INTO @Output SELECT 'StepInput', @stepInput;
    SELECT * FROM @Output;
END
