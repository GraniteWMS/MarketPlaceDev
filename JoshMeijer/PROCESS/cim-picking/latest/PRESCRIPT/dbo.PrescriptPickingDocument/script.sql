
CREATE   PROCEDURE [dbo].[PrescriptPickingDocument]
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
    DECLARE @valid bit = 1;
    DECLARE @message varchar(MAX) = '';
    DECLARE @stepInput varchar(MAX);
    SELECT @stepInput = [Value]
    FROM @input
    WHERE [Name] = 'StepInput';
    DECLARE @Document varchar(50) = @stepInput;
    DECLARE @DocumentID bigint;
    DECLARE @ERPLocation varchar(30);
    DECLARE @RequiredQty decimal(19,4);
    DECLARE @DocumentDetailBatch varchar(50);
    DECLARE @UserName varchar(100);
    DECLARE @PickerLocation varchar(100);
    DECLARE @LinesToAssign int = 5;
    DECLARE @AssignedCount int;
    DECLARE @AssignMessage varchar(MAX);
    DECLARE @DocumentDetailPickerOptionalFieldID bigint;
    SELECT @UserName = [Value]
    FROM @input
    WHERE [Name] = 'User';
    SELECT @PickerLocation = [Value]
    FROM @input
    WHERE [Name] = 'PickerLocation';
    SET @LinesToAssign = 5;
    SELECT TOP (1) @DocumentDetailPickerOptionalFieldID = ID
    FROM dbo.OptionalFields WITH (NOLOCK)
    WHERE [Name] = 'DocumentDetailPicker';
    IF EXISTS (SELECT 1 FROM dbo.Document WITH (NOLOCK) WHERE Number = CONCAT('D', @Document))
    BEGIN
        SELECT @stepInput = CONCAT('D', @Document);
    END;
    IF EXISTS (SELECT 1 FROM dbo.Document WITH (NOLOCK) WHERE Number = @Document AND [Type] = 'PICKSLIP')
    BEGIN
        SELECT @stepInput = @Document;
    END;
    IF EXISTS (SELECT 1 FROM dbo.Document WITH (NOLOCK) WHERE Number = CONCAT('D', @Document))
       OR EXISTS (SELECT 1 FROM dbo.Document WITH (NOLOCK) WHERE Number = @Document AND [Type] = 'PICKSLIP')
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
        IF @DocumentStatus IN ('CANCELED', 'CANCELLED', 'COMPLETE', 'COMPLETED')
        BEGIN
            SELECT @valid = 0;
            SELECT @message = CONCAT('Document ', @stepInput, ' has status ', @DocumentStatus);
            GOTO ScriptEnd;
        END;
        IF ISNULL(@DocumentDetailPickerOptionalFieldID, 0) = 0
        BEGIN
            SELECT @valid = 0;
            SELECT @message = 'Optional field DocumentDetailPicker does not exist.';
            GOTO ScriptEnd;
        END;
        IF ISNULL(@PickerLocation, '') = ''
        BEGIN
            SELECT @valid = 0;
            SELECT @message = 'PickerLocation was not supplied.';
            GOTO ScriptEnd;
        END;
        EXEC dbo.Custom_AssignDocumentDetailPicker_ByRecommendedWarehouse
              @DocumentID = @DocumentID
            , @UserName = @UserName
            , @PickerLocation = @PickerLocation
            , @LinesToAssign = @LinesToAssign
            , @AssignedCount = @AssignedCount OUTPUT
            , @Message = @AssignMessage OUTPUT;
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
              DD.Item_Id
            , DD.FromLocation
            , DD.Batch
            , SUM(ISNULL(DD.Qty, 0) - ISNULL(DD.ActionQty, 0))
        FROM dbo.DocumentDetail DD WITH (NOLOCK)
        INNER JOIN dbo.OptionalFieldValues_DocumentDetail OFV WITH (NOLOCK)
            ON OFV.BelongsTo_id = DD.ID
           AND OFV.OptionalField_id = @DocumentDetailPickerOptionalFieldID
           AND ISNULL(OFV.[Value], '') = @UserName
        WHERE DD.Document_id = @DocumentID
          AND ISNULL(DD.Cancelled, 0) = 0
          AND ISNULL(DD.Completed, 0) = 0
          AND ISNULL(DD.ActionQty, 0) < ISNULL(DD.Qty, 0)
        GROUP BY
              DD.Item_Id
            , DD.FromLocation
            , DD.Batch;
        SELECT @documentLines = COUNT(1)
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
            UPDATE DD
            SET DD.Instruction = @Instruction
            FROM dbo.DocumentDetail DD
            INNER JOIN dbo.OptionalFieldValues_DocumentDetail OFV
                ON OFV.BelongsTo_id = DD.ID
               AND OFV.OptionalField_id = @DocumentDetailPickerOptionalFieldID
               AND ISNULL(OFV.[Value], '') = @UserName
            WHERE DD.Document_id = @DocumentID
              AND DD.Item_id = @masterItemID
              AND DD.FromLocation = @ERPLocation
              AND ISNULL(DD.Cancelled, 0) = 0
              AND ISNULL(DD.Completed, 0) = 0
              AND ISNULL(DD.ActionQty, 0) < ISNULL(DD.Qty, 0)
              AND (
                    ISNULL(@DocumentDetailBatch, '') = ''
                    OR ISNULL(DD.Batch, '') = ISNULL(@DocumentDetailBatch, '')
                  );
            SELECT @counter = @counter + 1;
        END;
        SELECT @valid = 1;
        SELECT @message = ISNULL(@AssignMessage, '');
        DROP TABLE #tempTable;
    END
    ELSE
    BEGIN
        SELECT @valid = 0;
        SELECT @message = CONCAT(@Document, ' is not a valid SALES ORDER document');
    END;
ScriptEnd:
    INSERT INTO @Output SELECT 'Picker', @UserName
    INSERT INTO @Output SELECT 'Message', @message;
    INSERT INTO @Output SELECT 'Valid', @valid;
    INSERT INTO @Output SELECT 'StepInput', @stepInput;
    SELECT * FROM @Output;
END
