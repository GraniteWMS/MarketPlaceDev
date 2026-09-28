
CREATE   PROCEDURE [dbo].[PreScript_Consume_Step200]
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
        , @trackingEntityScanned varchar(50)
        , @masterItemID bigint
        , @documentNumber varchar(50)
        , @documentID bigint
        , @newInstruction nvarchar(MAX)
        , @currentInstruction nvarchar(MAX)
        , @RequiredQty decimal(19,6);
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
    SELECT @trackingEntityScanned = [Value]
    FROM @input
    WHERE [Name] = 'TrackingEntity';
    SELECT @documentNumber = [Value]
    FROM @input
    WHERE [Name] = 'Document';
    SELECT @documentID = D.ID
    FROM dbo.[Document] D
    WHERE D.[Number] = @documentNumber;
    SELECT @masterItemID = TE.MasterItem_id
    FROM dbo.TrackingEntity TE
    WHERE TE.Barcode = @trackingEntityScanned;
    SELECT
        @RequiredQty =
            SUM
            (
                ISNULL(DD.Qty, 0)
                - ISNULL(DD.ActionQty, 0)
            )
    FROM dbo.DocumentDetail DD
    WHERE DD.Document_id = @documentID
      AND DD.Item_id = @masterItemID
      AND DD.[Type] = 'INPUT'
      AND ISNULL(DD.Comment, '') <> 'EXSTRA RAW MATERIALS';
    SET @RequiredQty = ISNULL(@RequiredQty, 0);
    IF @documentID IS NULL
    BEGIN
        SELECT
              @valid = 0
            , @message = 'Document not found';
    END
    ELSE IF @masterItemID IS NULL
    BEGIN
        SELECT
              @valid = 0
            , @message = 'Barcode does not exist';
    END
    ELSE
    BEGIN
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
            @newInstruction =
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
        SELECT TOP (1)
            @currentInstruction = DD.Instruction
        FROM dbo.DocumentDetail DD
        WHERE DD.Document_id = @documentID
          AND DD.Item_id = @masterItemID
          AND DD.[Type] = 'INPUT';
        IF ISNULL(@currentInstruction, '') <> ISNULL(@newInstruction, '')
        BEGIN
            UPDATE dbo.DocumentDetail
            SET
                  Comment = ''
                , Instruction = @newInstruction
            WHERE Document_id = @documentID
              AND Item_id = @masterItemID
              AND [Type] = 'INPUT';
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
