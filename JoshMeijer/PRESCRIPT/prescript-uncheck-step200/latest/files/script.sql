CREATE PROCEDURE [dbo].[Prescript_Uncheck_Step200] (
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
DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT
DECLARE @DocumentNumber varchar(50)
DECLARE @Barcode varchar(50)
DECLARE @UserID bigint
DECLARE @User varchar(50)
DECLARE @NumberOfTransactionsToReverse bigint
DECLARE @CurrentDate datetime
DECLARE @UncheckType varchar(30)
DECLARE @DocumentID bigint
DECLARE @MasterItemID bigint
DECLARE @TransctionIDsToReverse TABLE
(ID bigint identity(1, 1),
TransactionID bigint)
SELECT @UncheckType = Value FROM @input WHERE Name = 'Type'
SELECT @DocumentNumber = Value FROM @input WHERE Name = 'Document'
SELECT @Barcode = Value FROM @input WHERE Name = 'Barcode'
SELECT @User = Value FROM @input WHERE Name = 'User'
SELECT @UserID = ID FROM Users WHERE [Name] = @User
SELECT @DocumentID = ID FROM Document WHERE Number = @DocumentNumber
SET @CurrentDate = GETDATE()
SET @valid = 1
SET @message = 'Successfully unpacked item'
IF @UncheckType = 'MASTERITEM'
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
		SELECT @MasterItemID = ID FROM MasterItem WHERE Code = @Barcode
		INSERT INTO @TransctionIDsToReverse (TransactionID)
		SELECT T.ID FROM [Transaction] T
		WHERE T.Document_id = @DocumentID AND T.FromMasterItem_id = @MasterItemID AND T.[Type] = 'PACK' AND ISNULL(ReversalTransaction_id, 0) = 0 
		SELECT @NumberOfTransactionsToReverse = COUNT(ID) FROM @TransctionIDsToReverse
		IF @NumberOfTransactionsToReverse > 0
		BEGIN
			INSERT INTO [Transaction] ([Date], FromQty, ToQty, ActionQty, DocumentDetailQty, FromDocumentDetailQty, ToDocumentDetailQty, UOMConversion, IntegrationStatus, IntegrationReady, TrackingEntity_id, ContainableEntity_id, [User_id], FromLocation_id, FromMasterItem_id, Document_id, DocumentLine_id, [Type], ActivityCost, ReversalTransaction_id, LinkedTransaction_id)
			SELECT @CurrentDate, 0, 0, ActionQty, 0, 0, 0, UOMConversion, 1, 1, TrackingEntity_id, ContainableEntity_id, @UserID, FromLocation_id, FromMasterItem_id, Document_id, DocumentLine_id, 'TRANSACTIONREVERSAL', 0, 0, ID
			FROM [Transaction] WHERE ID IN (SELECT TransactionID FROM @TransctionIDsToReverse)
			UPDATE [Transaction]
			SET ReversalTransaction_id = (SELECT T.ID FROM [Transaction] T WHERE T.LinkedTransaction_id = [Transaction].ID)
			WHERE ID IN (SELECT TransactionID FROM @TransctionIDsToReverse)
			INSERT INTO [dbo].[Audit]([AuditDate],[AuditTime],[User],[RecordID],[RecordVersion],[Application],[TableName],[ChangeType],[ColumnName],[PreviousValue],[NewValue])
			SELECT CAST(@CurrentDate as date), CAST(@CurrentDate as time), @User, ID, 1, 'PRESCRIPT', 'TrackingEntity', 'UPDATE', 'BelongsToEntity_id', BelongsToEntity_id, '' FROM TrackingEntity
			WHERE ID IN (SELECT TrackingEntity_id FROM [Transaction] WHERE ID IN (SELECT TransactionID FROM @TransctionIDsToReverse))
			UPDATE TrackingEntity
			SET BelongsToEntity_id = NULL
			WHERE ID IN (SELECT TrackingEntity_id FROM [Transaction] WHERE ID IN (SELECT TransactionID FROM @TransctionIDsToReverse))
			UPDATE [Transaction]
			SET LinkedTransaction_id = 0
			WHERE ID IN (SELECT TOP (@NumberOfTransactionsToReverse) ID FROM [Transaction] WHERE [Type] = 'TRANSACTIONREVERSAL' AND [User_id] = @UserID)
			INSERT INTO [dbo].[Audit]([AuditDate],[AuditTime],[User],[RecordID],[RecordVersion],[Application],[TableName],[ChangeType],[ColumnName],[PreviousValue],[NewValue])
			SELECT CAST(@CurrentDate as date), CAST(@CurrentDate as time), @User, ID, 1, 'PRESCRIPT', 'DocumentDetail', 'UPDATE', 'PackedQty', PackedQty, 0.0000 FROM DocumentDetail
			WHERE Item_id = @MasterItemID
			AND Document_id = @DocumentID
			UPDATE DocumentDetail
			SET PackedQty = 0
			WHERE Item_id = @MasterItemID
			AND Document_id = @DocumentID
		END
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE()
			SET @valid = 0
			SET @message = @ErrorMessage
	END CATCH
END
IF @UncheckType = 'TRACKINGENTITY'
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO @TransctionIDsToReverse (TransactionID)
		SELECT T.ID FROM [Transaction] T
		WHERE T.Document_id = @DocumentID AND T.Comment = @Barcode AND T.[Type] = 'PACK' AND ISNULL(T.ReversalTransaction_id, 0) = 0 
		SELECT @NumberOfTransactionsToReverse = COUNT(ID) FROM @TransctionIDsToReverse
		IF @NumberOfTransactionsToReverse > 0
		BEGIN
			INSERT INTO [Transaction] ([Date], FromQty, ToQty, ActionQty, DocumentDetailQty, FromDocumentDetailQty, ToDocumentDetailQty, UOMConversion, IntegrationStatus, IntegrationReady, TrackingEntity_id, ContainableEntity_id, [User_id], FromLocation_id, FromMasterItem_id, Document_id, DocumentLine_id, [Type], ActivityCost, ReversalTransaction_id, LinkedTransaction_id)
			SELECT @CurrentDate, 0, 0, ActionQty, 0, 0, 0, UOMConversion, 1, 1, TrackingEntity_id, ContainableEntity_id, @UserID, FromLocation_id, FromMasterItem_id, Document_id, DocumentLine_id, 'TRANSACTIONREVERSAL', 0, 0, ID
			FROM [Transaction] WHERE ID IN (SELECT TransactionID FROM @TransctionIDsToReverse)
			UPDATE [Transaction]
			SET ReversalTransaction_id = (SELECT T.ID FROM [Transaction] T WHERE T.LinkedTransaction_id = [Transaction].ID)
			WHERE ID IN (SELECT TransactionID FROM @TransctionIDsToReverse)
			INSERT INTO [dbo].[Audit]([AuditDate],[AuditTime],[User],[RecordID],[RecordVersion],[Application],[TableName],[ChangeType],[ColumnName],[PreviousValue],[NewValue])
			SELECT CAST(@CurrentDate as date), CAST(@CurrentDate as time), @User, ID, 1, 'PRESCRIPT', 'TrackingEntity', 'UPDATE', 'BelongsToEntity_id', BelongsToEntity_id, '' FROM TrackingEntity
			WHERE ID IN (SELECT TrackingEntity_id FROM [Transaction] WHERE ID IN (SELECT TransactionID FROM @TransctionIDsToReverse))
			UPDATE TrackingEntity
			SET BelongsToEntity_id = NULL
			WHERE ID IN (SELECT TrackingEntity_id FROM [Transaction] WHERE ID IN (SELECT TransactionID FROM @TransctionIDsToReverse))
			UPDATE [Transaction]
			SET LinkedTransaction_id = 0
			WHERE ID IN (SELECT TOP (@NumberOfTransactionsToReverse) ID FROM [Transaction] WHERE [Type] = 'TRANSACTIONREVERSAL' AND [User_id] = @UserID)
			INSERT INTO [dbo].[Audit]([AuditDate],[AuditTime],[User],[RecordID],[RecordVersion],[Application],[TableName],[ChangeType],[ColumnName],[PreviousValue],[NewValue])
			SELECT CAST(@CurrentDate as date), CAST(@CurrentDate as time), @User, DD.ID, 1, 'PRESCRIPT', 'DocumentDetail', 'UPDATE', 'PackedQty', PackedQty,  PackedQty - T.ActionQty FROM [Transaction] T
			INNER JOIN [DocumentDetail] DD ON T.DocumentLine_id = DD.ID
			WHERE T.Document_id = @DocumentID AND T.ID IN (SELECT TransactionID FROM @TransctionIDsToReverse)
			
			UPDATE DocumentDetail
			SET PackedQty = PackedQty - T.ActionQty
			FROM [Transaction] T
			WHERE T.Document_id = @DocumentID
			AND DocumentDetail.ID = T.DocumentLine_id
			AND T.ID IN (SELECT TransactionID FROM @TransctionIDsToReverse)
		END
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE()
			SET @valid = 0
			SET @message = @ErrorMessage
	END CATCH
END
IF @UncheckType = 'SERIALNUMBER'
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO @TransctionIDsToReverse (TransactionID)
		SELECT T.ID FROM [Transaction] T
		INNER JOIN TrackingEntity TE ON T.TrackingEntity_id = TE.ID 
		WHERE T.Document_id = @DocumentID AND TE.SerialNumber = @stepInput AND ISNULL(T.ReversalTransaction_id, 0) = 0 AND T.[Type] = 'PACK'
		SELECT @NumberOfTransactionsToReverse = COUNT(ID) FROM @TransctionIDsToReverse
		IF @NumberOfTransactionsToReverse > 0
		BEGIN
			INSERT INTO [Transaction] ([Date], FromQty, ToQty, ActionQty, DocumentDetailQty, FromDocumentDetailQty, ToDocumentDetailQty, UOMConversion, IntegrationStatus, IntegrationReady, TrackingEntity_id, ContainableEntity_id, [User_id], FromLocation_id, FromMasterItem_id, Document_id, DocumentLine_id, [Type], ActivityCost, ReversalTransaction_id, LinkedTransaction_id)
			SELECT @CurrentDate, 0, 0, ActionQty, 0, 0, 0, UOMConversion, 1, 1, TrackingEntity_id, ContainableEntity_id, @UserID, FromLocation_id, FromMasterItem_id, Document_id, DocumentLine_id, 'TRANSACTIONREVERSAL', 0, 0, ID
			FROM [Transaction] WHERE ID IN (SELECT TransactionID FROM @TransctionIDsToReverse)
			UPDATE [Transaction]
			SET ReversalTransaction_id = (SELECT T.ID FROM [Transaction] T WHERE T.LinkedTransaction_id = [Transaction].ID)
			WHERE ID IN (SELECT TransactionID FROM @TransctionIDsToReverse)
			INSERT INTO [dbo].[Audit]([AuditDate],[AuditTime],[User],[RecordID],[RecordVersion],[Application],[TableName],[ChangeType],[ColumnName],[PreviousValue],[NewValue])
			SELECT CAST(@CurrentDate as date), CAST(@CurrentDate as time), @User, ID, 1, 'PRESCRIPT', 'TrackingEntity', 'UPDATE', 'BelongsToEntity_id', BelongsToEntity_id, '' FROM TrackingEntity
			WHERE ID IN (SELECT TrackingEntity_id FROM [Transaction] WHERE ID IN (SELECT TransactionID FROM @TransctionIDsToReverse))
			UPDATE TrackingEntity
			SET BelongsToEntity_id = NULL
			WHERE ID IN (SELECT TrackingEntity_id FROM [Transaction] WHERE ID IN (SELECT TransactionID FROM @TransctionIDsToReverse))
			UPDATE [Transaction]
			SET LinkedTransaction_id = 0
			WHERE ID IN (SELECT TOP (@NumberOfTransactionsToReverse) ID FROM [Transaction] WHERE [Type] = 'TRANSACTIONREVERSAL' AND [User_id] = @UserID)
			INSERT INTO [dbo].[Audit]([AuditDate],[AuditTime],[User],[RecordID],[RecordVersion],[Application],[TableName],[ChangeType],[ColumnName],[PreviousValue],[NewValue])
			SELECT CAST(@CurrentDate as date), CAST(@CurrentDate as time), @User, DD.ID, 1, 'PRESCRIPT', 'DocumentDetail', 'UPDATE', 'PackedQty', PackedQty,  PackedQty - T.ActionQty FROM [Transaction] T
			INNER JOIN [DocumentDetail] DD ON T.DocumentLine_id = DD.ID
			WHERE T.Document_id = @DocumentID AND T.ID IN (SELECT TransactionID FROM @TransctionIDsToReverse)
			
			UPDATE DocumentDetail
			SET PackedQty = PackedQty - T.ActionQty
			FROM [Transaction] T
			WHERE T.Document_id = @DocumentID
			AND DocumentDetail.ID = T.DocumentLine_id
			AND T.ID IN (SELECT TransactionID FROM @TransctionIDsToReverse)
		END
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE()
			SET @valid = 0
			SET @message = @ErrorMessage
	END CATCH
END
IF @UncheckType = 'PALLET'
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO @TransctionIDsToReverse (TransactionID)
		SELECT T.ID FROM [Transaction] T
		WHERE T.Document_id = @DocumentID AND T.Comment = @Barcode AND T.[Type] = 'PACK' AND ISNULL(T.ReversalTransaction_id, 0) = 0 
		SELECT @NumberOfTransactionsToReverse = COUNT(ID) FROM @TransctionIDsToReverse
		IF @NumberOfTransactionsToReverse > 0
		BEGIN
			INSERT INTO [Transaction] ([Date], FromQty, ToQty, ActionQty, DocumentDetailQty, FromDocumentDetailQty, ToDocumentDetailQty, UOMConversion, IntegrationStatus, IntegrationReady, TrackingEntity_id, ContainableEntity_id, [User_id], FromLocation_id, FromMasterItem_id, Document_id, DocumentLine_id, [Type], ActivityCost, ReversalTransaction_id, LinkedTransaction_id)
			SELECT @CurrentDate, 0, 0, ActionQty, 0, 0, 0, UOMConversion, 1, 1, TrackingEntity_id, ContainableEntity_id, @UserID, FromLocation_id, FromMasterItem_id, Document_id, DocumentLine_id, 'TRANSACTIONREVERSAL', 0, 0, ID
			FROM [Transaction] WHERE ID IN (SELECT TransactionID FROM @TransctionIDsToReverse)
			UPDATE [Transaction]
			SET ReversalTransaction_id = (SELECT T.ID FROM [Transaction] T WHERE T.LinkedTransaction_id = [Transaction].ID)
			WHERE ID IN (SELECT TransactionID FROM @TransctionIDsToReverse)
			INSERT INTO [dbo].[Audit]([AuditDate],[AuditTime],[User],[RecordID],[RecordVersion],[Application],[TableName],[ChangeType],[ColumnName],[PreviousValue],[NewValue])
			SELECT CAST(@CurrentDate as date), CAST(@CurrentDate as time), @User, ID, 1, 'PRESCRIPT', 'TrackingEntity', 'UPDATE', 'BelongsToEntity_id', BelongsToEntity_id, '' FROM TrackingEntity
			WHERE ID IN (SELECT TrackingEntity_id FROM [Transaction] WHERE ID IN (SELECT TransactionID FROM @TransctionIDsToReverse))
			UPDATE TrackingEntity
			SET BelongsToEntity_id = NULL
			WHERE ID IN (SELECT TrackingEntity_id FROM [Transaction] WHERE ID IN (SELECT TransactionID FROM @TransctionIDsToReverse))
			UPDATE [Transaction]
			SET LinkedTransaction_id = 0
			WHERE ID IN (SELECT TOP (@NumberOfTransactionsToReverse) ID FROM [Transaction] WHERE [Type] = 'TRANSACTIONREVERSAL' AND [User_id] = @UserID)
			INSERT INTO [dbo].[Audit]([AuditDate],[AuditTime],[User],[RecordID],[RecordVersion],[Application],[TableName],[ChangeType],[ColumnName],[PreviousValue],[NewValue])
			SELECT CAST(@CurrentDate as date), CAST(@CurrentDate as time), @User, DD.ID, 1, 'PRESCRIPT', 'DocumentDetail', 'UPDATE', 'PackedQty', PackedQty,  PackedQty - T.ActionQty FROM [Transaction] T
			INNER JOIN [DocumentDetail] DD ON T.DocumentLine_id = DD.ID
			WHERE T.Document_id = @DocumentID AND T.ID IN (SELECT TransactionID FROM @TransctionIDsToReverse)
			
			UPDATE DocumentDetail
			SET PackedQty = PackedQty - T.ActionQty
			FROM [Transaction] T
			WHERE T.Document_id = @DocumentID
			AND DocumentDetail.ID = T.DocumentLine_id
			AND T.ID IN (SELECT TransactionID FROM @TransctionIDsToReverse)
		END
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE()
			SET @valid = 0
			SET @message = @ErrorMessage
	END CATCH
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
