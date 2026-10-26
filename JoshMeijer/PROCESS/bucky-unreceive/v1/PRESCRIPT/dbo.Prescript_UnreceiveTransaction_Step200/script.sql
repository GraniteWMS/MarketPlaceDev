CREATE PROCEDURE [dbo].[Prescript_UnreceiveTransaction_Step200] (
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
@TransactionID bigint = (SELECT Value FROM @input WHERE Name = 'TransactionID')
,@UserID bigint
,@User varchar(50) = (SELECT Value FROM @input WHERE Name = 'User')
,@NumberOfTransactionsToReverse bigint
,@CurrentDateTime datetime = GETDATE()
SELECT @UserID = ID FROM Users WHERE [Name] = @User
DECLARE @TransactionIDsToReverse TABLE
(ID bigint identity(1, 1),
TransactionID bigint)
DECLARE @ReversalTransactionIDs TABLE
(ID bigint identity(1, 1),
TransactionID bigint
)
DECLARE @NewDocumentDetailQuantities TABLE
(DocumentLineID bigint,
Qty decimal(19, 4))
DECLARE @NewTrackingEntityQuantities TABLE
(
TrackingEntityID bigint,
QtyToDecrease decimal(19, 4)
)
BEGIN TRY
BEGIN TRANSACTION
		INSERT INTO @TransactionIDsToReverse (TransactionID)
		SELECT @TransactionID
		SELECT @NumberOfTransactionsToReverse = COUNT(ID) FROM @TransactionIDsToReverse
		IF @NumberOfTransactionsToReverse > 0
		BEGIN
			RAISERROR('There are no transactions to reverse', 16, 1)
		END
		INSERT INTO @NewDocumentDetailQuantities (DocumentLineID, Qty)
		SELECT DocumentLine_id, SUM(ActionQty)
		FROM [Transaction]
		WHERE ID IN (SELECT TransactionID FROM @TransactionIDsToReverse)
		GROUP BY DocumentLine_id
		INSERT INTO @NewTrackingEntityQuantities (TrackingEntityID, QtyToDecrease)
		SELECT TrackingEntity_id, SUM(ActionQty)
		FROM [Transaction]
		WHERE ID IN (SELECT TransactionID FROM @TransactionIDsToReverse)
		GROUP BY TrackingEntity_id
		INSERT INTO [Transaction] ([Date], FromQty, ToQty, ActionQty, DocumentDetailQty, FromDocumentDetailQty, ToDocumentDetailQty, UOMConversion, IntegrationStatus, IntegrationReady, TrackingEntity_id, FromContainableEntity_id, ToContainableEntity_id, [User_id], FromLocation_id, FromMasterItem_id, Document_id, DocumentLine_id, [Type], ActivityCost, ReversalTransaction_id, LinkedTransaction_id)
		OUTPUT INSERTED.ID INTO @ReversalTransactionIDs
		SELECT @CurrentDateTime, 0, 0, ActionQty, 0, 0, 0, UOMConversion, 1, 1, TrackingEntity_id, FromContainableEntity_id, ToContainableEntity_id, @UserID, FromLocation_id, FromMasterItem_id, Document_id, DocumentLine_id, 'TRANSACTIONREVERSAL', 0, 0, ID
		FROM [Transaction] WHERE ID IN (SELECT TransactionID FROM @TransactionIDsToReverse)
		UPDATE [Transaction]
		SET ReversalTransaction_id = (SELECT T.ID FROM [Transaction] T WHERE T.LinkedTransaction_id = [Transaction].ID)
		WHERE ID IN (SELECT TransactionID FROM @TransactionIDsToReverse)
		UPDATE TrackingEntity
		SET BelongsToEntity_id = NULL
		WHERE ID IN (SELECT TrackingEntity_id FROM [Transaction] WHERE ID IN (SELECT TransactionID FROM @TransactionIDsToReverse))
		UPDATE [Transaction]
		SET LinkedTransaction_id = 0
		WHERE ID IN (SELECT TransactionID FROM @ReversalTransactionIDs)
		INSERT INTO [dbo].[Audit]([AuditDate],[AuditTime],[User],[RecordID],[RecordVersion],[Application],[TableName],[ChangeType],[ColumnName],[PreviousValue],[NewValue])
		SELECT CAST(@CurrentDateTime as date), CAST(@CurrentDateTime as time), @User, DD.ID, 1, 'PRESCRIPT', 'DocumentDetail', 'UPDATE', 'ActionQty', ActionQty,  ActionQty - NewQuantities.Qty 
		FROM @NewDocumentDetailQuantities NewQuantities
		INNER JOIN [DocumentDetail] DD ON NewQuantities.DocumentLineID = DD.ID
			
		UPDATE DocumentDetail
		SET 
		ActionQty -= NewQuantities.Qty,
		Completed = 0
		FROM @NewDocumentDetailQuantities NewQuantities
		WHERE ID = NewQuantities.DocumentLineID
		UPDATE TrackingEntity
		SET Qty -= NewQuantities.QtyToDecrease
		FROM @NewTrackingEntityQuantities NewQuantities
		WHERE ID = NewQuantities.TrackingEntityID
		SELECT @valid = 1,
		@message = 'Successfully Reversed Transaction'
COMMIT TRANSACTION
END TRY
BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END
		SELECT 
		@message = ERROR_MESSAGE(),
		@valid = 0
END CATCH
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
