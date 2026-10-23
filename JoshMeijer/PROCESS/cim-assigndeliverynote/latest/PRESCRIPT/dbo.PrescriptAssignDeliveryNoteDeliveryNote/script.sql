CREATE PROCEDURE [dbo].[PrescriptAssignDeliveryNoteDeliveryNote] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @type varchar(20)
DECLARE @document varchar(30)
DECLARE @documentId bigint
DECLARE @Location varchar(30)
DECLARE @User varchar(30)
DECLARE @ERPLocation varchar(30)
DECLARE @DocumentERPLocation varchar(30)
DECLARE @PickSlipNumber varchar(30)
DECLARE @PickSlipID bigint
DECLARE @InsertedLines TABLE
(
      NewDocumentDetailID bigint
    , OldDocumentDetailID bigint
)
SELECT @document = CONCAT('D', @stepInput)
SELECT @type = Value 
FROM @input
WHERE [Name] = 'Type'
SELECT @PickSlipNumber = Value 
FROM @input
WHERE [Name] = 'PickSlip'
SELECT @Location = Value
FROM @input
WHERE [Name] = 'Location'
SELECT @User = Value 
FROM @input
WHERE [Name] = 'User'
SELECT @ERPLocation = ERPLocation
FROM dbo.[Location]
WHERE Barcode = @Location
SELECT @PickSlipID = ID
FROM dbo.Document
WHERE Number = @PickSlipNumber
  AND [Type] = 'PICKSLIP'
IF ISNULL(@type, '') NOT IN ('ADD', 'REMOVE')
BEGIN
    SELECT @valid = 0
    SELECT @message = 'Invalid action. Action must be ADD or REMOVE.'
    GOTO ScriptEnd
END
IF ISNULL(@PickSlipNumber, '') = ''
BEGIN
    SELECT @valid = 0
    SELECT @message = 'Pickslip was not supplied.'
    GOTO ScriptEnd
END
IF @PickSlipID IS NULL
BEGIN
    SELECT @valid = 0
    SELECT @message = CONCAT('Pickslip ', @PickSlipNumber, ' not found.')
    GOTO ScriptEnd
END
IF ISNULL(@Location, '') = ''
BEGIN
    SELECT @valid = 0
    SELECT @message = 'Loading bay was not supplied.'
    GOTO ScriptEnd
END
IF ISNULL(@ERPLocation, '') = ''
BEGIN
    SELECT @valid = 0
    SELECT @message = CONCAT('Loading bay ', @Location, ' is not linked to a valid ERP location.')
    GOTO ScriptEnd
END
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.Document
    WHERE Number = @document
      AND [Type] = 'ORDER'
      AND Number LIKE 'D%'
)
BEGIN
    SELECT @valid = 0
    SELECT @message = CONCAT('Not a valid delivery note document ', @document, '.')
    GOTO ScriptEnd
END
SELECT
      @documentId = ID
    , @DocumentERPLocation = ERPLocation
FROM dbo.Document
WHERE Number = @document
  AND [Type] = 'ORDER'
IF @type = 'REMOVE'
BEGIN
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.DocumentDetail PSDD
        INNER JOIN dbo.DocumentDetail DNDD
            ON PSDD.LinkedDetail_id = DNDD.ID
        WHERE PSDD.Document_id = @PickSlipID
          AND DNDD.Document_id = @documentId
          AND ISNULL(DNDD.FromLocation, @DocumentERPLocation) = @ERPLocation
    )
    BEGIN
        SELECT @valid = 0
        SELECT @message = CONCAT('Delivery note document ', @document, ' does not match pickslip ', @PickSlipNumber, ' for ERP location ', @ERPLocation, '.')
        GOTO ScriptEnd
    END
    IF EXISTS
    (
        SELECT 1
        FROM dbo.[Transaction] T
        INNER JOIN dbo.DocumentDetail DNDD
            ON T.DocumentLine_id = DNDD.ID
        INNER JOIN dbo.DocumentDetail PSDD
            ON PSDD.LinkedDetail_id = DNDD.ID
        WHERE PSDD.Document_id = @PickSlipID
          AND DNDD.Document_id = @documentId
          AND ISNULL(DNDD.FromLocation, @DocumentERPLocation) = @ERPLocation
          AND T.Process LIKE 'PICK%'
          AND ISNULL(T.ActionQty, 0) > 0
    )
    BEGIN
        SELECT @valid = 0
        SELECT @message = CONCAT('Cannot remove delivery note ', @document, '. It has already been scanned against pickslip ', @PickSlipNumber, '.')
        GOTO ScriptEnd
    END
    DELETE PSDD
    FROM dbo.DocumentDetail PSDD
    INNER JOIN dbo.DocumentDetail DNDD
        ON PSDD.LinkedDetail_id = DNDD.ID
    WHERE PSDD.Document_id = @PickSlipID
      AND DNDD.Document_id = @documentId
      AND ISNULL(DNDD.FromLocation, @DocumentERPLocation) = @ERPLocation
    EXEC dbo.Custom_DeliveryNoteLoadingBay_Set
        @Action = 'REMOVE',
        @DocumentID = @documentId,
        @UserName = @User,
        @Comments = 'Removed from loading bay';
    SELECT @valid = 1
    SELECT @message = CONCAT('Delivery note document ', @document, ' has been removed from bay ', @Location, ' for ERP location ', @ERPLocation, '.')
    GOTO ScriptEnd
END
IF EXISTS
(
    SELECT 1
    FROM dbo.Document
    WHERE ID = @documentId
      AND [Status] IN ('CANCELLED', 'CANCELED')
)
BEGIN
    SELECT @valid = 0
    SELECT @message = CONCAT('Delivery note document ', @document, ' has been cancelled.')
    GOTO ScriptEnd
END
IF EXISTS
(
    SELECT 1
    FROM dbo.Document
    WHERE ID = @documentId
      AND [Status] IN ('COMPLETE', 'COMPLETED')
)
BEGIN
    SELECT @valid = 0
    SELECT @message = CONCAT('Delivery note document ', @document, ' has already been completed.')
    GOTO ScriptEnd
END
IF ISNULL(@DocumentERPLocation, @ERPLocation) <> @ERPLocation
BEGIN
    SELECT @valid = 0
    SELECT @message = CONCAT('Delivery note document ', @document, ' is for ', @DocumentERPLocation, ' but the selected loading bay is for ', @ERPLocation, '.')
    GOTO ScriptEnd
END
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.DocumentDetail
    WHERE Document_id = @documentId
      AND ISNULL(FromLocation, @DocumentERPLocation) = @ERPLocation
      AND ISNULL(Cancelled, 0) = 0
)
BEGIN
    SELECT @valid = 0
    SELECT @message = CONCAT('Delivery note document ', @document, ' has no valid lines for ERP location ', @ERPLocation, '.')
    GOTO ScriptEnd
END
IF EXISTS
(
    SELECT 1
    FROM dbo.DocumentDetail PSDD
    INNER JOIN dbo.Document PS
        ON PS.ID = PSDD.Document_id
       AND PS.[Type] = 'PICKSLIP'
    INNER JOIN dbo.DocumentDetail DNDD
        ON PSDD.LinkedDetail_id = DNDD.ID
    WHERE DNDD.Document_id = @documentId
      AND ISNULL(DNDD.FromLocation, @DocumentERPLocation) = @ERPLocation
      AND PSDD.Document_id <> @PickSlipID
)
BEGIN
    SELECT @valid = 0
    SELECT @message = CONCAT('Delivery note document ', @document, ' for ERP location ', @ERPLocation, ' is already linked to another pickslip.')
    GOTO ScriptEnd
END
IF EXISTS
(
    SELECT 1
    FROM dbo.DocumentDetail PSDD
    INNER JOIN dbo.DocumentDetail DNDD
        ON PSDD.LinkedDetail_id = DNDD.ID
    WHERE PSDD.Document_id = @PickSlipID
      AND DNDD.Document_id = @documentId
      AND ISNULL(DNDD.FromLocation, @DocumentERPLocation) = @ERPLocation
)
BEGIN
    SELECT @valid = 0
    SELECT @message = CONCAT('Delivery note document ', @document, ' already exists on pickslip ', @PickSlipNumber, ' for ERP location ', @ERPLocation, '.')
    GOTO ScriptEnd
END
EXEC dbo.Custom_DeliveryNoteLoadingBay_Set
    @Action = 'ASSIGN',
    @DocumentID = @documentId,
    @LoadingBay = @Location,
    @UserName = @User,
    @Comments = 'Assigned from scanner';
;MERGE dbo.DocumentDetail AS tgt
USING
(
    SELECT
          src.ID
        , @PickSlipID AS Document_id
        , src.LineNumber
        , src.Item_id
        , src.Qty
        , CAST(0 AS decimal(19, 6)) AS ActionQty
        , src.ID AS LinkedDetail_id
        , src.Comment
        , src.Instruction
        , CAST(0 AS bit) AS Cancelled
        , CAST(0 AS bit) AS Completed
        , src.UOM
        , src.Batch
        , src.ExpiryDate
        , src.SerialNumber
        , src.FromLocation
        , src.ToLocation
        , src.ERPIdentification
    FROM dbo.DocumentDetail src
    WHERE src.Document_id = @documentId
      AND ISNULL(src.FromLocation, @DocumentERPLocation) = @ERPLocation
      AND ISNULL(src.Cancelled, 0) = 0
) AS src
    ON 1 = 0
WHEN NOT MATCHED THEN
    INSERT
    (
          Document_id
        , LineNumber
        , Item_id
        , Qty
        , ActionQty
        , LinkedDetail_id
        , Comment
        , Instruction
        , Cancelled
        , Completed
        , UOM
        , Batch
        , ExpiryDate
        , SerialNumber
        , FromLocation
        , ToLocation
        , ERPIdentification
    )
    VALUES
    (
          src.Document_id
        , src.LineNumber
        , src.Item_id
        , src.Qty
        , src.ActionQty
        , src.LinkedDetail_id
        , src.Comment
        , src.Instruction
        , src.Cancelled
        , src.Completed
        , src.UOM
        , src.Batch
        , src.ExpiryDate
        , src.SerialNumber
        , src.FromLocation
        , src.ToLocation
        , src.ERPIdentification
    )
OUTPUT
      inserted.ID
    , src.ID
INTO @InsertedLines
(
      NewDocumentDetailID
    , OldDocumentDetailID
);
UPDATE oldDD
SET oldDD.LinkedDetail_id = map.NewDocumentDetailID
FROM dbo.DocumentDetail oldDD
INNER JOIN @InsertedLines map
    ON oldDD.ID = map.OldDocumentDetailID
SELECT @valid = 1
SELECT @message = CONCAT('Delivery note document ', @document, ' has been assigned to bay ', @Location, ' and added to pickslip ', @PickSlipNumber, ' for ERP location ', @ERPLocation, '.')
GOTO ScriptEnd
ScriptEnd:
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
