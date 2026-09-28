CREATE PROCEDURE [dbo].[Prescript_UntransferTransaction_Step200] (
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
,@TrackingEntityID bigint
SELECT @UserID = ID FROM Users WHERE [Name] = @User
DECLARE @TransactionIDsToReverse TABLE
(ID bigint identity(1, 1),
TransactionID bigint)
BEGIN TRY
BEGIN TRANSACTION
		INSERT INTO @TransactionIDsToReverse (TransactionID)
		SELECT @TransactionID
		SELECT @NumberOfTransactionsToReverse = COUNT(ID) FROM @TransactionIDsToReverse
		IF @NumberOfTransactionsToReverse = 0
		BEGIN
			RAISERROR('There are no transactions to reverse', 16, 1)
		END
		SELECT @TrackingEntityID = TrackingEntity_id FROM [Transaction] WHERE ID = @TransactionID
		EXECUTE [dbo].[clr_TransferReversal] 
	   @userName = @User
	  ,@transactionIds = @TransactionID
	  ,@documentNumber = NULL
	  ,@lineNumber = NULL
	  ,@comment = NULL
	  ,@integrationReference = NULL
	  ,@processName = 'UNTRANSFER'
	  ,@success = @valid OUTPUT
	  ,@message = @message OUTPUT
	  IF @valid = 1
	  BEGIN
		UPDATE TrackingEntity
		SET OnHold = 0
		WHERE ID = @TrackingEntityID AND OnHold = 1
	  END
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
