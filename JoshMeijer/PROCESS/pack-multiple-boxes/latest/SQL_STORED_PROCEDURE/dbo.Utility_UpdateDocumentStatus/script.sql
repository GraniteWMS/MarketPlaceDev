CREATE PROCEDURE [dbo].[Utility_UpdateDocumentStatus]
(@DocumentNumber varchar(100),
@NewStatus varchar(50),
@User varchar(50))
AS
BEGIN
DECLARE @DocumentID bigint
DECLARE @CurrentDate datetime
DECLARE @CurrentStatus varchar(50)
SELECT @CurrentDate = GETDATE()
SELECT @DocumentID = ID FROM Document WHERE Number = @DocumentNumber
SELECT @CurrentStatus = [Status] FROM Document WHERE ID = @DocumentID
IF @CurrentStatus <> @NewStatus
BEGIN
	UPDATE Document SET [Status] = @NewStatus WHERE ID = @DocumentID
	INSERT INTO [dbo].[Audit]([AuditDate],[AuditTime],[User],[RecordID],[RecordVersion],[Application],[TableName],[ChangeType],[ColumnName],[PreviousValue],[NewValue])
	SELECT CAST(@CurrentDate AS DATE),CAST(@CurrentDate AS TIME),@User,@DocumentID,1,'PRESCRIPT','Document','UPDATE','Status',@CurrentStatus,@NewStatus
END
END