
CREATE   PROCEDURE [dbo].[PrescriptPickingStep200]
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
    DECLARE @ERPLocation varchar(30);
    DECLARE @locationID bigint;
    DECLARE @trackingEntityScanned varchar(50);
    DECLARE @masterItemID bigint;
    DECLARE @documentNumber varchar(50);
    DECLARE @documentID bigint;
    DECLARE @nextTrackingEntity varchar(50);
    DECLARE @nextTrackingEntityQty decimal(19,4);
    DECLARE @locationName varchar(50);
    DECLARE @TrackingEntityBatch varchar(50);
    DECLARE @newInstruction varchar(MAX);
    DECLARE @currentInstruction varchar(MAX);
    DECLARE @RequiredQty decimal(19,4);
    DECLARE @DocumentDetailBatch varchar(50);
    DECLARE @RecommendationValid bit;
    DECLARE @RecommendationMessage varchar(max);
    DECLARE @UserName varchar(100);
    DECLARE @PickerLocation varchar(100);
    DECLARE @LinesToAssign int = 5;
    DECLARE @AssignedCount int;
    DECLARE @AssignMessage varchar(MAX);
    DECLARE @DocumentDetailPickerOptionalFieldID bigint;
    SELECT @trackingEntityScanned = [Value]
    FROM @input
    WHERE [Name] = 'TrackingEntity';
    SELECT @documentNumber = [Value]
    FROM @input
    WHERE [Name] = 'Document';
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
    SELECT @documentID = ID
    FROM dbo.Document WITH (NOLOCK)
    WHERE Number = @documentNumber;
    SELECT
          @masterItemID = TE.MasterItem_id
        , @locationID = TE.Location_id
        , @TrackingEntityBatch = TE.Batch
    FROM dbo.TrackingEntity TE WITH (NOLOCK)
    WHERE TE.Barcode = @trackingEntityScanned;
    SELECT @ERPLocation = ERPLocation
    FROM dbo.Location WITH (NOLOCK)
    WHERE ID = @locationID;
    IF @documentID IS NULL
    BEGIN
        SELECT @valid = 0;
        SELECT @message = 'Document not found';
        GOTO ScriptEnd;
    END;
    ELSE IF @masterItemID IS NULL
    BEGIN
        SELECT @valid = 0;
        SELECT @message = 'Barcode does not exist';
        GOTO ScriptEnd;
    END;
    ELSE IF ISNULL(@DocumentDetailPickerOptionalFieldID, 0) = 0
    BEGIN
        SELECT @valid = 0;
        SELECT @message = 'Optional field DocumentDetailPicker does not exist.';
        GOTO ScriptEnd;
    END;
    ELSE IF ISNULL(@PickerLocation, '') = ''
    BEGIN
        SELECT @valid = 0;
        SELECT @message = 'PickerLocation was not supplied.';
        GOTO ScriptEnd;
    END;
    EXEC dbo.Custom_AssignDocumentDetailPicker_ByRecommendedWarehouse
          @DocumentID = @documentID
        , @UserName = @UserName
        , @PickerLocation = @PickerLocation
        , @LinesToAssign = @LinesToAssign
        , @AssignedCount = @AssignedCount OUTPUT
        , @Message = @AssignMessage OUTPUT;
    SELECT TOP (1)
        @DocumentDetailBatch = DD.Batch
    FROM dbo.DocumentDetail DD WITH (NOLOCK)
    INNER JOIN dbo.OptionalFieldValues_DocumentDetail OFV WITH (NOLOCK)
        ON OFV.BelongsTo_id = DD.ID
       AND OFV.OptionalField_id = @DocumentDetailPickerOptionalFieldID
       AND ISNULL(OFV.[Value], '') = @UserName
    WHERE DD.Document_id = @documentID
      AND DD.Item_id = @masterItemID
      AND DD.FromLocation = @ERPLocation
      AND ISNULL(DD.Cancelled, 0) = 0
      AND ISNULL(DD.Completed, 0) = 0
      AND ISNULL(DD.ActionQty, 0) < ISNULL(DD.Qty, 0)
      AND (
            ISNULL(DD.Batch, '') = ''
            OR ISNULL(DD.Batch, '') = ISNULL(@TrackingEntityBatch, '')
          );
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    SELECT @RequiredQty = SUM(ISNULL(DD.Qty, 0) - ISNULL(DD.ActionQty, 0))
    FROM dbo.DocumentDetail DD WITH (NOLOCK)
    INNER JOIN dbo.OptionalFieldValues_DocumentDetail OFV WITH (NOLOCK)
        ON OFV.BelongsTo_id = DD.ID
       AND OFV.OptionalField_id = @DocumentDetailPickerOptionalFieldID
       AND ISNULL(OFV.[Value], '') = @UserName
    WHERE DD.Document_id = @documentID
      AND DD.Item_id = @masterItemID
      AND DD.FromLocation = @ERPLocation
      AND ISNULL(DD.Cancelled, 0) = 0
      AND ISNULL(DD.Completed, 0) = 0
      AND ISNULL(DD.ActionQty, 0) < ISNULL(DD.Qty, 0)
      AND (
            ISNULL(@DocumentDetailBatch, '') = ''
            OR ISNULL(DD.Batch, '') = ISNULL(@DocumentDetailBatch, '')
          );
    SET @RequiredQty = ISNULL(@RequiredQty, 0);
    EXEC dbo.Custom_GetRecommendedBarcode
          @MasterItemID = @masterItemID
        , @ERPLocation = @ERPLocation
        , @RequiredQty = @RequiredQty
        , @DocumentDetailBatch = @DocumentDetailBatch
        , @AdjustedBarcode = NULL
        , @AdjustedQtyToRemove = 0
        , @RecommendedBarcode = @nextTrackingEntity OUTPUT
        , @RecommendedQty = @nextTrackingEntityQty OUTPUT
        , @RecommendedBatch = @TrackingEntityBatch OUTPUT
        , @RecommendedLocationName = @locationName OUTPUT
        , @Instruction = @newInstruction OUTPUT
        , @Valid = @RecommendationValid OUTPUT
        , @Message = @RecommendationMessage OUTPUT;
    SELECT TOP (1)
        @currentInstruction = DD.Instruction
    FROM dbo.DocumentDetail DD WITH (NOLOCK)
    INNER JOIN dbo.OptionalFieldValues_DocumentDetail OFV WITH (NOLOCK)
        ON OFV.BelongsTo_id = DD.ID
       AND OFV.OptionalField_id = @DocumentDetailPickerOptionalFieldID
       AND ISNULL(OFV.[Value], '') = @UserName
    WHERE DD.Document_id = @documentID
      AND DD.Item_id = @masterItemID
      AND DD.FromLocation = @ERPLocation
      AND ISNULL(DD.Cancelled, 0) = 0
      AND ISNULL(DD.Completed, 0) = 0
      AND ISNULL(DD.ActionQty, 0) < ISNULL(DD.Qty, 0)
      AND (
            ISNULL(@DocumentDetailBatch, '') = ''
            OR ISNULL(DD.Batch, '') = ISNULL(@DocumentDetailBatch, '')
          );
    IF ISNULL(@currentInstruction, '') <> ISNULL(@newInstruction, '')
    BEGIN
        UPDATE DD
        SET DD.Instruction = @newInstruction
        FROM dbo.DocumentDetail DD
        INNER JOIN dbo.OptionalFieldValues_DocumentDetail OFV
            ON OFV.BelongsTo_id = DD.ID
           AND OFV.OptionalField_id = @DocumentDetailPickerOptionalFieldID
           AND ISNULL(OFV.[Value], '') = @UserName
        WHERE DD.Document_id = @documentID
          AND DD.Item_id = @masterItemID
          AND DD.FromLocation = @ERPLocation
          AND ISNULL(DD.Cancelled, 0) = 0
          AND ISNULL(DD.Completed, 0) = 0
          AND ISNULL(DD.ActionQty, 0) < ISNULL(DD.Qty, 0)
          AND (
                ISNULL(@DocumentDetailBatch, '') = ''
                OR ISNULL(DD.Batch, '') = ISNULL(@DocumentDetailBatch, '')
              );
    END;
    SELECT @valid = 1;
    SELECT @message = ISNULL(@AssignMessage, '');
ScriptEnd:
    INSERT INTO @Output SELECT 'Picker', @UserName
    INSERT INTO @Output SELECT 'Message', @message;
    INSERT INTO @Output SELECT 'Valid', @valid;
    INSERT INTO @Output SELECT 'StepInput', @stepInput;
    SELECT * FROM @Output;
END
