CREATE PROCEDURE [dbo].[PrescriptPackingStep200] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
    Name varchar(max),  
    Value varchar(max)  
)
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) =''
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value 
FROM @input 
WHERE Name = 'StepInput';
DECLARE 
    @DocumentNumber VARCHAR(100),
    @TrackingBarcode VARCHAR(100),
    @UserName VARCHAR(100),
    @DocumentID BIGINT,
    @TrackingEntityID BIGINT,
    @MasterItemID BIGINT,
    @UserID BIGINT,
    @LastTransactionID BIGINT;
SELECT @DocumentNumber = Value FROM @input WHERE Name = 'Document';
SELECT @TrackingBarcode = Value FROM @input WHERE Name = 'MasterItem';
SELECT @UserName = Value FROM @input WHERE Name = 'User';
SELECT @DocumentID = ID 
FROM dbo.[Document] 
WHERE [Number] = @DocumentNumber;
SELECT 
    @TrackingEntityID = ID,
    @MasterItemID = MasterItem_id
FROM dbo.TrackingEntity 
WHERE Barcode = @TrackingBarcode;
SELECT @UserID = ID 
FROM dbo.[Users] 
WHERE [Name] = @UserName;
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
END
INSERT INTO @Output
SELECT 'Message', @message;
INSERT INTO @Output
SELECT 'Valid', @valid;
INSERT INTO @Output
SELECT 'StepInput', @stepInput;
SELECT * FROM @Output;
