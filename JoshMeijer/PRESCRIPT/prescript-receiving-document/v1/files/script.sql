CREATE PROCEDURE [dbo].[Prescript_Receiving_Document] (
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
DECLARE @Status varchar(20)
DECLARE @Document varchar(100) = @stepInput
DECLARE @ERP_id varchar(100)
BEGIN TRY
	SELECT @Status = [Status] FROM Document WHERE Number =@Document and [Type] ='RECEIVING'
	IF isnull(@status,'') = '' 
	BEGIN
		SELECT @ERP_id = PORHSEQ FROM [PINTST].dbo.POPORH1 WHERE PONUMBER = @Document COLLATE SQL_Latin1_General_CP1_CI_AS
		INSERT INTO IntegrationDocumentQueue(ERP_id,DocumentNumber,DocumentType,Status,LastUpdateDateTime)
		SELECT @ERP_id, @Document,'RECEIVING','ENTERED', getdate()
		Raiserror('The Document does not exist or is not integrated yet -if it exists, try again in 5 minutes',16,1)
			
	
	END
	
	UPDATE Document SET [Status] = 'RELEASED' WHERE Number = @Document
		
	SELECT @valid = 1
	SELECT @message = @stepInput
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
