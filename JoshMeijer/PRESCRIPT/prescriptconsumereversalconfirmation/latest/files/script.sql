CREATE PROCEDURE [dbo].[PrescriptConsumeReversalConfirmation] (
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



DECLARE @Document varchar(50)
DECLARE @DocumentID bigint
DECLARE @DocumentDetailID bigint
DECLARE @DocumentDetailQty decimal(19,4)
DECLARE @DocumentDetailActionQty decimal(19,4)
DECLARE @TrackingEntityID bigint
DECLARE @TrackingEntityQty decimal(19,4)
DECLARE @ConsumeTransactionID bigint
DECLARE @ReversalTransactionID bigint
DECLARE @MasterItemID bigint
DECLARE @ReversalQty decimal(19,4)
DECLARE @ConsumeQty decimal(19,4)
DECLARE @User varchar(50)
DECLARE @UserID bigint
DECLARE @LocationID bigint

SELECT @Document = Value FROM @input WHERE Name = 'Document'
SELECT @ConsumeTransactionID = Value FROM @input WHERE Name = 'TransactionID'

SELECT @User = Value FROM @input WHERE Name = 'User'

IF @stepInput = 'Yes'
BEGIN
	SELECT @UserID = ID
	FROM Users
	WHERE [Name] = @User

	SELECT @ConsumeQty = ActionQty, @ReversalQty = ActionQty, @TrackingEntityID = TrackingEntity_id, @LocationID = FromLocation_id,
		   @DocumentID = Document_id, @DocumentDetailID = DocumentLine_id, @MasterItemID = FromMasterItem_id
	FROM [Transaction]
	WHERE [Type] = 'CONSUME'
	  AND ID = @ConsumeTransactionID

	SELECT @DocumentDetailQty = Qty, @DocumentDetailActionQty = ActionQty
	FROM DocumentDetail
	WHERE Document_id = @DocumentID
	  AND ID = @DocumentDetailID

	SELECT @TrackingEntityQty = Qty
	FROM TrackingEntity
	WHERE ID = @TrackingEntityID

	IF ISNULL(@TrackingEntityID,0) > 0
	BEGIN
		INSERT INTO [dbo].[Transaction]
				   ([Date]
				   ,[FromQty]
				   ,[ToQty]
				   ,[ActionQty]
				   ,[DocumentDetailQty]
				   ,[FromDocumentDetailQty]
				   ,[ToDocumentDetailQty]
				   ,[UOM]
				   ,[UOMConversion]
				   ,[DocumentReference]
				   ,[Comment]
				   ,[IntegrationStatus]
				   ,[IntegrationReady]
				   ,[IntegrationDate]
				   ,[IntegrationReference]
				   ,[FromValue]
				   ,[ToValue]
				   ,[TrackingEntity_id]
				   ,[ContainableEntity_id]
				   ,[FromTrackingEntity_id]
				   ,[User_id]
				   ,[FromLocation_id]
				   ,[ToLocation_id]
				   ,[FromMasterItem_id]
				   ,[ToMasterItem_id]
				   ,[Document_id]
				   ,[DocumentLine_id]
				   ,[OptionalField_id]
				   ,[Type]
				   ,[Process]
				   ,[ActivityCost]
				   ,[ReversalTransaction_id]
				   ,[LinkedTransaction_id])
			 VALUES
				   (GETDATE()								
				   ,@TrackingEntityQty						
				   ,@TrackingEntityQty + @ReversalQty		
				   ,@ReversalQty							
				   ,@DocumentDetailQty						
				   ,@DocumentDetailActionQty				
				   ,@DocumentDetailActionQty - @ReversalQty	
				   ,NULL									
				   ,0										
				   ,NULL									
				   ,NULL									
				   ,0										
				   ,0										
				   ,NULL									
				   ,NULL									
				   ,NULL									
				   ,NULL									
				   ,@TrackingEntityID						
				   ,NULL									
				   ,NULL									
				   ,@UserID									
				   ,@LocationID								
				   ,@LocationID								
				   ,@MasterItemID							
				   ,NULL									
				   ,@DocumentID								
				   ,@DocumentDetailID						
				   ,NULL									
				   ,'CONSUMEREVERSAL'						
				   ,'CONSUMEREVERSAL'						
				   ,0										
				   ,0										
				   ,0										
				   )

		SELECT TOP 1 @ReversalTransactionID = ID
		FROM [Transaction]
		WHERE [Type] = 'CONSUMEREVERSAL'
		  AND Document_id = @DocumentID
		  AND [User_id] = @UserID
		ORDER BY [Date] DESC

		UPDATE [Transaction]
		SET ReversalTransaction_id = @ReversalTransactionID
		WHERE ID = @ConsumeTransactionID

		UPDATE DocumentDetail
		SET ActionQty = ActionQty - @ReversalQty,
			Qty = CASE WHEN ActionQty - @ReversalQty < PackedQty
					   THEN PackedQty
					   ELSE ActionQty - @ReversalQty
					   END,
			Completed = CASE WHEN ActionQty - @ReversalQty < PackedQty
							 THEN 0
							 ELSE Completed
							 END
		WHERE ID = @DocumentDetailID

		UPDATE TrackingEntity
		SET Qty = Qty + @ReversalQty
		WHERE ID = @TrackingEntityID

		SELECT @valid = 1
		SELECT @message = ''
	END
	ELSE
	BEGIN
		SELECT @valid = 0
		SELECT @message = 'Reversal failed.'
	END
END
ELSE
BEGIN
	SELECT @valid = 1
	SELECT @message = '' 
END




	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
