
CREATE   PROCEDURE [dbo].[PreScript_Consume_Document]
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
        , @salesOrderDocumentNumber varchar(20)
        , @salesOrderDocumentId bigint
        , @DocumentStatus varchar(30);
    DECLARE @Output TABLE
    (
          [Name] varchar(MAX)
        , [Value] varchar(MAX)
    );
    SELECT @stepInput = [Value]
    FROM @input
    WHERE [Name] = 'StepInput';
    SET @salesOrderDocumentNumber = LTRIM(RTRIM(@stepInput));
    SELECT
          @salesOrderDocumentId = D.ID
        , @DocumentStatus = D.[Status]
    FROM dbo.[Document] D
    WHERE D.[Number] = @salesOrderDocumentNumber;
    IF @salesOrderDocumentId IS NULL
    BEGIN
        SELECT
              @valid = 0
            , @message = CONCAT
              (
                  'Document ',
                  @salesOrderDocumentNumber,
                  ' does not exist'
              );
    END
    ELSE IF @DocumentStatus IN ('CANCELED', 'CANCELLED')
    BEGIN
        SELECT
              @valid = 0
            , @message = CONCAT
              (
                  'Document ',
                  @salesOrderDocumentNumber,
                  ' has been CANCELED'
              );
    END
    ELSE
    BEGIN
        DECLARE @Lines TABLE
        (
              ID int IDENTITY(1,1)
            , MasterItemID bigint NOT NULL
            , RequiredQty decimal(19,6) NOT NULL
        );
        INSERT INTO @Lines
        (
              MasterItemID
            , RequiredQty
        )
        SELECT
              DD.Item_id
            , SUM(ISNULL(DD.Qty, 0))
              - SUM(ISNULL(DD.ActionQty, 0))
        FROM dbo.DocumentDetail DD
        WHERE DD.Document_id = @salesOrderDocumentId
          AND DD.[Type] = 'INPUT'
          AND ISNULL(DD.Comment, '') <> 'EXSTRA RAW MATERIALS'
          AND
          (
              ISNULL(DD.Qty, 0)
              - ISNULL(DD.ActionQty, 0)
          ) > 0
        GROUP BY DD.Item_id;
        SELECT TOP (1)
            @Warehouse = OFV.[Value]
        FROM dbo.OptionalFieldValues_Document OFV WITH (NOLOCK)
        WHERE OFV.BelongsTo_id = @salesOrderDocumentId
          AND OFV.OptionalField_Id = 4;
        SET @Warehouse =
            UPPER
            (
                LTRIM
                (
                    RTRIM(ISNULL(@Warehouse, 'SAVOURY'))
                )
            );
        DECLARE
              @counter int = 1
            , @maxCounter int
            , @masterItemID bigint
            , @RequiredQty decimal(19,6)
            , @Instruction nvarchar(MAX);
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
        SELECT @maxCounter = COUNT(*)
        FROM @Lines;
        WHILE @counter <= @maxCounter
        BEGIN
            SELECT
                  @masterItemID = L.MasterItemID
                , @RequiredQty = L.RequiredQty
            FROM @Lines L
            WHERE L.ID = @counter;
            DELETE FROM @Recommendations;
            SET @Instruction = NULL;
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
            UPDATE dbo.DocumentDetail
            SET
                  Comment = ''
                , Instruction = @Instruction
            WHERE Document_id = @salesOrderDocumentId
              AND Item_id = @masterItemID
              AND ISNULL(Comment, '') <> 'EXSTRA RAW MATERIALS'
              AND [Type] = 'INPUT';
            SET @counter += 1;
        END;
        SELECT
              @valid = 1
            , @message = '';
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
