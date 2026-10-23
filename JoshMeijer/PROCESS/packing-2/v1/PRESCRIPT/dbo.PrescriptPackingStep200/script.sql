CREATE   PROCEDURE  [dbo].[PrescriptPackingStep200] (
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
DECLARE 
    @DocumentNumber VARCHAR(100),
    @TrackingBarcode VARCHAR(100),
    @UserName VARCHAR(100),
    @DocumentID BIGINT,
    @TrackingEntityID BIGINT,
    @MasterItemID BIGINT,
    @UserID BIGINT,
	@InvoiceNumber varchar(50),
    @LastTransactionID BIGINT,
    @PackedQty DECIMAL(18,6),
    @ExpectedQty DECIMAL(18,6),
    @ClrMessage NVARCHAR(MAX),
    @Success BIT = 0;
SELECT @DocumentNumber = Value FROM @input WHERE Name = 'Document';
SELECT @TrackingBarcode = Value FROM @input WHERE Name = 'MasterItem';
SELECT @UserName = Value FROM @input WHERE Name = 'User';
INSERT INTO dbo.PackingProcessLog (LogOrigin, DocumentNumber, UserName, TrackingBarcode, Step, Message)
VALUES ('PrescriptPackingStep200', @DocumentNumber, @UserName, @TrackingBarcode, 'INPUT', 'Inputs fetched from Granite.');
SELECT @DocumentID = ID FROM dbo.[Document] WHERE [Number] = @DocumentNumber;
SELECT 
    @TrackingEntityID = ID,
    @MasterItemID = MasterItem_id
FROM dbo.TrackingEntity 
WHERE Barcode = @TrackingBarcode;
SELECT @UserID = ID FROM dbo.[Users] WHERE [Name] = @UserName;
INSERT INTO dbo.PackingProcessLog (LogOrigin, DocumentNumber, UserName, TrackingBarcode, Step, Message, DocumentID)
VALUES (
    'PrescriptPackingStep200', @DocumentNumber, @UserName, @TrackingBarcode, 'RESOLVE_IDS',
    CONCAT('Resolved IDs. DocumentID=', ISNULL(@DocumentID,0),
           ', TrackingEntityID=', ISNULL(@TrackingEntityID,0),
           ', MasterItemID=', ISNULL(@MasterItemID,0),
           ', UserID=', ISNULL(@UserID,0)), 
    @DocumentID
);
SELECT TOP (1)
    @LastTransactionID = ID
FROM dbo.[Transaction]
WHERE 
    [Process] = 'PACKING'
    AND Document_id = @DocumentID
    AND FromMasterItem_id = @MasterItemID
    AND [User_id] = @UserID
	AND ReversalTransaction_id = 0
ORDER BY [Date] DESC, ID DESC;
IF @LastTransactionID IS NOT NULL
BEGIN
    UPDATE dbo.[Transaction]
    SET FromTrackingEntity_id = @TrackingEntityID
    WHERE ID = @LastTransactionID;
    INSERT INTO dbo.PackingProcessLog (LogOrigin, DocumentNumber, UserName, TrackingBarcode, Step, Message, DocumentID, TransactionID)
    VALUES (
        'PrescriptPackingStep200', @DocumentNumber, @UserName, @TrackingBarcode, 'UPDATE_TRANSACTION',
        CONCAT('Updated FromTrackingEntity_id to ', @TrackingEntityID, ' for TransactionID ', @LastTransactionID), 
        @DocumentID, @LastTransactionID
    );
END
ELSE
BEGIN
    INSERT INTO dbo.PackingProcessLog (LogOrigin, DocumentNumber, UserName, TrackingBarcode, Step, Message, DocumentID)
    VALUES (
        'PrescriptPackingStep200', @DocumentNumber, @UserName, @TrackingBarcode, 'UPDATE_TRANSACTION',
        'No packing transaction found to update.', @DocumentID
    );
END;
SELECT @ExpectedQty = SUM(ISNULL(ActionQty,0))
FROM dbo.DocumentDetail
WHERE Document_id = @DocumentID;
SELECT @PackedQty = SUM(ISNULL(PackedQty,0))
FROM dbo.DocumentDetail
WHERE Document_id = @DocumentID;
INSERT INTO dbo.PackingProcessLog (LogOrigin, DocumentNumber, UserName, TrackingBarcode, Step, Message, DocumentID)
VALUES (
    'PrescriptPackingStep200', @DocumentNumber, @UserName, @TrackingBarcode, 'PACKING_STATUS',
    CONCAT('ExpectedQty=', ISNULL(@ExpectedQty,0), ', PackedQty=', ISNULL(@PackedQty,0)), @DocumentID
);
IF ISNULL(@PackedQty,0) < ISNULL(@ExpectedQty,0)
BEGIN
    SET @valid = 1;
    SET @message = CONCAT(
        'Packing not yet complete. ', 
        ISNULL(@PackedQty,0), ' of ', ISNULL(@ExpectedQty,0), ' packed.'
    );
    INSERT INTO dbo.PackingProcessLog (LogOrigin, DocumentNumber, UserName, TrackingBarcode, Step, Message, DocumentID)
    VALUES (
        'PrescriptPackingStep200', @DocumentNumber, @UserName, @TrackingBarcode, 'PACKING_STATUS',
        @message, @DocumentID
    );
    GOTO CompleteReturn;
END;
BEGIN TRY
	Update P
	SET IntegrationIsActive = 1, IntegrationPost = 0
	FROM Process P
	WHERE Name = 'PICKING'
    EXEC dbo.[clr_IntegrationPost]
        @transactionID = NULL,
        @document = @DocumentNumber,
        @documents = NULL,
        @reference = '',
        @transactionType = 'Pick',
        @processName = 'Picking',
        @success = @Success OUTPUT,
        @message = @ClrMessage OUTPUT;
	INSERT INTO dbo.PackingProcessLog (LogOrigin, DocumentNumber, UserName, TrackingBarcode, Step, Message, DocumentID, Success)
    VALUES (
        'PrescriptPackingStep200', @DocumentNumber, @UserName, @TrackingBarcode, 'PickingIntegrationStatusUpdate',
        CONCAT(@message, 'IntegrationIsActive: ', (SELECT Top 1 IntegrationIsActive FROM Process WHERE Name = 'PICKING'), 'IntegrationPost: ', (SELECT Top 1 IntegrationPost FROM Process WHERE Name = 'PICKING')), @DocumentID, @Success
    );
	WAITFOR DELAY '00:00:02';
	Update P
	SET IntegrationIsActive = 0, IntegrationPost = 0
	FROM Process P
	WHERE Name = 'PICKING'
    IF (@Success = 1)
    BEGIN
        SET @valid = 1;
        SET @message = CONCAT('Packing complete. Integration post successful: ', @ClrMessage);
    END
    ELSE
    BEGIN
        SET @valid = 0;
        SET @message = CONCAT('Packing complete but integration post failed: ', @ClrMessage);
    END
    INSERT INTO dbo.PackingProcessLog (LogOrigin, DocumentNumber, UserName, TrackingBarcode, Step, Message, DocumentID, Success)
    VALUES (
        'PrescriptPackingStep200', @DocumentNumber, @UserName, @TrackingBarcode, 'CLR_POST',
        @message, @DocumentID, @Success
    );
	SELECT TOP 1 @InvoiceNumber = IntegrationReference 
	FROM [Transaction] (NOLOCK)
	WHERE Document_id = @documentID 
	AND IntegrationStatus = 1 
	AND ISNULL(IntegrationReference,'') <> '' 
	AND TYPE = 'PICK' 
	ORDER BY ID Desc
	
	
	
	
	
	
	INSERT INTO dbo.PackingProcessLog (LogOrigin, DocumentNumber, UserName, TrackingBarcode, Step, Message, DocumentID, Success)
    VALUES (
        'PrescriptPackingStep200', @DocumentNumber, @UserName, @TrackingBarcode, 'CLR_PRINT',
        'Refer to Custom_ReportPrintLog for more details', @DocumentID, 1
    );
END TRY
BEGIN CATCH
    SET @valid = 0;
    SET @message = CONCAT('Error while posting packing document: ', ERROR_MESSAGE());
    INSERT INTO dbo.PackingProcessLog (LogOrigin, DocumentNumber, UserName, TrackingBarcode, Step, Message, DocumentID, Success)
    VALUES (
        'PrescriptPackingStep200', @DocumentNumber, @UserName, @TrackingBarcode, 'CLR_POST_ERROR',
        @message, @DocumentID, 0
    );
END CATCH;
CompleteReturn:
INSERT INTO dbo.PackingProcessLog (LogOrigin, DocumentNumber, UserName, TrackingBarcode, Step, Message, DocumentID, Success)
VALUES (
    'PrescriptPackingStep200', @DocumentNumber, @UserName, @TrackingBarcode, 'COMPLETE',
    CONCAT('Returned message: ', @message), @DocumentID, @valid
);
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
