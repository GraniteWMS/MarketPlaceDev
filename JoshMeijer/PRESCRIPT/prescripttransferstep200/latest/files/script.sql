CREATE   PROCEDURE [dbo].[PrescriptTransferStep200]
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
    DECLARE @RecommendationMessage varchar(max)
    DECLARE @DestinationLocation varchar(30);
    SELECT @trackingEntityScanned = Value
    FROM @input
    WHERE Name = 'TrackingEntity';
    SELECT @documentNumber = Value
    FROM @input
    WHERE Name = 'Document';
    SELECT @DestinationLocation = Value
    FROM @input
    WHERE Name = 'DestinationLocation';
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
    END
    ELSE IF @masterItemID IS NULL
    BEGIN
        SELECT @valid = 0;
        SELECT @message = 'Barcode does not exist';
    END
    ELSE
    BEGIN
        SELECT TOP (1)
            @DocumentDetailBatch = DD.Batch
        FROM dbo.DocumentDetail DD WITH (NOLOCK)
        WHERE DD.Document_id = @documentID
          AND DD.Item_id = @masterItemID
          AND DD.FromLocation = @ERPLocation
          AND DD.ToLocation = @DestinationLocation
          AND ISNULL(DD.Cancelled, 0) = 0
          AND (
                ISNULL(DD.Batch, '') = ''
                OR ISNULL(DD.Batch, '') = ISNULL(@TrackingEntityBatch, '')
              );
        SELECT @RequiredQty = SUM(ISNULL(DD.Qty, 0))
        FROM dbo.DocumentDetail DD WITH (NOLOCK)
        WHERE DD.Document_id = @documentID
          AND DD.Item_id = @masterItemID
          AND DD.FromLocation = @ERPLocation
          AND DD.ToLocation = @DestinationLocation
          AND ISNULL(DD.Cancelled, 0) = 0
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
            @currentInstruction = Instruction
        FROM dbo.DocumentDetail WITH (NOLOCK)
        WHERE Document_id = @documentID
          AND Item_id = @masterItemID
          AND FromLocation = @ERPLocation
          AND ToLocation = @DestinationLocation
          AND ISNULL(Cancelled, 0) = 0
          AND (
                ISNULL(@DocumentDetailBatch, '') = ''
                OR ISNULL(Batch, '') = ISNULL(@DocumentDetailBatch, '')
              );
        IF ISNULL(@currentInstruction, '') <> ISNULL(@newInstruction, '')
        BEGIN
            UPDATE dbo.DocumentDetail
            SET Instruction = @newInstruction
            WHERE Document_id = @documentID
              AND Item_id = @masterItemID
              AND FromLocation = @ERPLocation
              AND ISNULL(Cancelled, 0) = 0
              AND (
                    ISNULL(@DocumentDetailBatch, '') = ''
                    OR ISNULL(Batch, '') = ISNULL(@DocumentDetailBatch, '')
                  );
        END;
        SELECT @valid = 1;
        SELECT @message = '';
    END;
    INSERT INTO @Output SELECT 'Message', @message;
    INSERT INTO @Output SELECT 'Valid', @valid;
    INSERT INTO @Output SELECT 'StepInput', @stepInput;
    SELECT * FROM @Output;
END
