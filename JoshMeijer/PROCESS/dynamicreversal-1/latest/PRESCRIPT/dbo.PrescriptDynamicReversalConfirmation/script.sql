CREATE PROCEDURE [dbo].[PrescriptDynamicReversalConfirmation] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE @stepInput varchar(MAX)  = (SELECT Value FROM @input WHERE Name = 'StepInput')
DECLARE @TrackingEntity varchar(50) =(SELECT Value FROM @input WHERE Name = 'TrackingEntity')
DECLARE @TrackingEntity_ID bigint
DECLARE @Document varchar(50) = (SELECT Value FROM @input WHERE Name = 'Document' )
DECLARE @User varchar(50) = (SELECT Value from @input WHERE Name = 'User')
DECLARE @Comment varchar(100) = (SELECT Value from @input WHERE Name = 'Comment')
DECLARE @Document_id bigint
DECLARE @User_id bigint   = (SELECT ID FROM [Users] WHERE Name = @User)
DECLARE @TransactionID BIGINT
DECLARE @TrackingEntityID BIGINT
DECLARE @DocumentDetailID BIGINT
DECLARE @ActionQty Decimal(19,4)
DECLARE @ReversalTX_id BIGINT
BEGIN TRY
	SELECT @Document_id = ID FROM Document WHERE Number = @Document
	IF isnull(@Document_id,0) = 0
	BEGIN
		SELECT @message = 'Order Document Not found'
		SELECT @valid = 0
	END
	ELSE
	BEGIN
		SELECT @TransactionID= ID, @TrackingEntityID = TrackingEntity_id, @DocumentDetailID = DocumentLine_id, @ActionQty = ActionQty
		FROM [Transaction] WHERE Document_id = @Document_id
		AND TrackingEntity_id = (SELECT ID FROM TrackingEntity WHERE Barcode = @TrackingEntity)
		INSERT INTO [Transaction] (Date,FromQty,ToQty,Actionqty,IntegrationStatus,IntegrationReady,TrackingEntity_id,[User_id], FromLocation_id, FromMasterItem_id,Document_id,[Type],Comment)
		SELECT [Date],0,ActionQty,ActionQty, 1,1,@TrackingEntityID,@User_id,FromLocation_id, FromMasterItem_id,Document_id,'TRANSACTIONREVERSAL',@Document +':'+ CONVERT(varchar(10),@DocumentDetailID)+ ':'+ @TrackingEntity +'>'+ @Comment
		FROM [Transaction] WHERE ID = @TransactionID
		SELECT @ReversalTX_id = SCOPE_IDENTITY() 
		UPDATE [Transaction] SET ReversalTransaction_id = @ReversalTX_id, Comment = @Comment, @DocumentDetailID = NULL
		WHERE ID = @TransactionID
		Delete FROM DocumentDetail WHERE ID = @DocumentDetailID 
		UPDATE TrackingEntity SET Qty = @ActionQty WHERE ID = @TrackingEntityID
		SELECT @message = 'Tracking Entity returned to Stock'
		SELECT @valid = 1
	END
END TRY
BEGIN CATCH
	SELECT @message = ERROR_MESSAGE()
	SELECT @valid = 0
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
