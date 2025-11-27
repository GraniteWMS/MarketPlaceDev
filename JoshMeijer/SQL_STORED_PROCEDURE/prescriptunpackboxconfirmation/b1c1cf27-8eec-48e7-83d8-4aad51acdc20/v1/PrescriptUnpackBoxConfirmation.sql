CREATE PROCEDURE [dbo].[PrescriptUnpackBoxConfirmation] (
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
DECLARE @PackingEntityNumber varchar(30) 
	SELECT @PackingEntityNumber = Value FROM @input WHERE Name = 'Barcode'
DECLARE @PackingEntityId bigint	
	SELECT @PackingEntityId = ID From CarryingEntity WHERE Barcode = @PackingEntityNumber
DECLARE @MasterItemCode varchar(30)
	SELECT @MasterItemCode = Value FROM @input WHERE Name = 'MasterItem'
DECLARE @MasterItemId bigint	
DECLARE @User varchar(30)
	SELECT @User =  Value FROM @input WHERE Name = 'User'
DECLARE @UserId bigint
	SELECT @UserId = ID FROM Users WHERE Name = @User

SELECT @MasterItemId = ID From masterItem WHERE Code = @MasterItemCode
IF (ISNULL(@MasterItemId, 0) = 0)
	SELECT @MasterItemId = MasterItem_id FROM MasterItemAlias WHERE Code = @MasterItemCode

IF EXISTS (SELECT * FROM [Transaction] WHERE	Type = 'PACK'	
												AND IntegrationStatus = 0 
												AND ContainableEntity_id = @PackingEntityId 
												AND ReversalTransaction_id IN (NULL, 0) 
												AND FromMasterItem_id = @MasterItemId)
	BEGIN
		IF (@stepInput = 'Yes')
		BEGIN 

			DECLARE @PackReversalLines TABLE (
			TransactionId bigint, 
			PackedQty decimal(19,4),
			TotalPackedQty decimal(19,4),
			TrackingEntityId bigint,
			CarryingEntityId bigint,
			MasterItemId bigint,
			DocumentLineId bigint, 
			LocationId bigint,
			ReversalId bigint
			)

			INSERT INTO @PackReversalLines
			SELECT ID, 
				   ActionQty,
				   0,
				   TrackingEntity_id,
				   ContainableEntity_id,
				   FromMasterItem_id,
				   DocumentLine_id, 
				   FromLocation_id,
				   0
			FROM [Transaction]
			WHERE IntegrationStatus = 0 AND
				  [Transaction].Type = 'Pack' AND 
				  [Transaction].ReversalTransaction_id IN (NULL, 0) AND
				  FromMasterItem_id = @MasterItemId AND 
				  ContainableEntity_id = @PackingEntityId

			UPDATE @PackReversalLines
			SET TotalPackedQty = (SELECT SUM(PackedQty) FROM @PackReversalLines)

			SELECT * FROM @PackReversalLines

			
			INSERT INTO [Transaction] (Date, FromQty, ToQty, ActionQty, FromDocumentDetailQty, ToDocumentDetailQty, FromMasterItem_id, Document_id, DocumentLine_id, Type, Process, TrackingEntity_id, User_id)
			SELECT DISTINCT GETDATE(), 
				   DocumentDetail.PackedQty,
				   DocumentDetail.PackedQty - TotalPackedQty,
				   TotalPackedQty,
				   DocumentDetail.PackedQty,
				   DocumentDetail.PackedQty - TotalPackedQty,
				   DocumentDetail.Item_id,
				   Document_id,
				   DocumentLineId,
				   'UNPACK',
				   'UNPACK',
				   TrackingEntityId, 
				   @UserId
			FROM DocumentDetail INNER JOIN 
				 @PackReversalLines AS PackReversalLines ON DocumentDetail.ID = DocumentLineId


			
			UPDATE DocumentDetail
			SET PackedQty = QtyReversed FROM (SELECT DocumentLineId,(DocumentDetail.PackedQty - TotalPackedQty) as QtyReversed
			FROM DocumentDetail INNER JOIN 
				 @PackReversalLines AS PackReversalLines ON DocumentDetail.ID = DocumentLineId) AS PackReverse
			WHERE DocumentDetail.ID = DocumentLineId

			
			UPDATE TrackingEntity
			SET BelongsToEntity_id = NULL
			WHERE ID IN (SELECT TrackingEntityId FROM @PackReversalLines)

			
			UPDATE @PackReversalLines 
			SET ReversalId = ID FROM [Transaction]
			WHERE DocumentLine_id = DocumentLineId AND 
				  Type = 'UNPACK'

			
			UPDATE [Transaction]
			SET ReversalTransaction_id = ReversalId FROM @PackReversalLines
			WHERE ID IN (SELECT TransactionId FROM @PackReversalLines)

			SELECT @valid = 1
			SELECT @message = @MasterItemCode + ' Unpacked'

		END
		ELSE
		BEGIN 
			SELECT @valid = 1
			SELECT @message = 'UNPACK CANCELLED'
		END
	END
ELSE
	BEGIN 
		SELECT @valid = 1
		SELECT @message = 'MasterItem not packed in this box'
	END


INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput


SELECT * FROM @Output
