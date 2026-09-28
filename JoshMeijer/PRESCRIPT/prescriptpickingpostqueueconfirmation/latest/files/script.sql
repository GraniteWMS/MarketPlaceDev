CREATE PROCEDURE [dbo].[PrescriptPickingPostQueueConfirmation] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max), 
  Value varchar(max)
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @Document varchar(50)
SELECT @Document = Value FROM @input WHERE Name = 'Document'
DECLARE @ERP_ID varchar(50)
BEGIN TRY
	IF @stepInput NOT in ('Y','YES','Yes')
		RAISERROR('Not confirmed - no action taken',16,1)
		
	SELECT @ERP_ID = ERPIdentification FROM Document WHERE Number = @Document
	INSERT INTO IntegrationDocumentPostingQueue (ERP_id,DocumentNumber,DocumentType, [Status],LastUpdateDateTime)
	SELECT @ERP_ID, @Document,'ORDER','ENTERED',getdate()
	SELECT @valid = 1
	SELECT @message = 'Order ' + @Document + ' inserted into Posting Queue'
	
END TRY
BEGIN CATCH
	SELECT @valid = 0
	,@message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
