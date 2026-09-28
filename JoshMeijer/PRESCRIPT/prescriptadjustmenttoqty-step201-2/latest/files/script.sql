CREATE PROCEDURE [dbo].[PrescriptAdjustmentToQty_Step201] (
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
SELECT @stepInput = Value FROM @input WHERE [Name] = 'StepInput' 
DECLARE @userName varchar(50)
SELECT  @userName = Value FROM @input WHERE [Name] = 'User'
DECLARE @userID bigint
SELECT @userID = ID FROM [Users] WHERE [Name] = @userName
DECLARE @transactionID nvarchar(max)
SELECT @transactionID = ID
FROM [Integration_Transactions]
WHERE [Type] = 'ADJUSTMENT'
AND [Process] = 'ADJUSTTOQTY'
AND [User] = @userName
AND DateDIFF(SECOND,[Date],getdate()) <60
ORDER BY ID DESC
DECLARE @document nvarchar(max)
DECLARE @documentReference nvarchar(max)
DECLARE @documents nvarchar(max)
DECLARE @reference nvarchar(max)
DECLARE @transactionType nvarchar(max) = 'ADJUSTMENT'
DECLARE @processName nvarchar(max) = 'ADJUSTTOQTY'
DECLARE @success bit
BEGIN TRY
IF ISNULL(@transactionID,0) =0	
	RAISERROR('No Integration to ERP Done -The Integration Record doesnt exist or integration is not set up',16,1)
	EXECUTE [dbo].[clr_IntegrationPost] 
   @transactionID
  ,@document
  ,@documentReference
  ,@documents
  ,@reference
  ,@transactionType
  ,@processName
  ,@success OUTPUT
  ,@message OUTPUT
	IF @success = 0
	BEGIN
		RAISERROR(@message, 16, 1);
	END
	SELECT 
	@valid = 1,
	@message = @stepInput
END TRY
BEGIN CATCH
	SELECT
	@valid = 0,
	@message = ERROR_MESSAGE()
END CATCH
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
