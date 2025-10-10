CREATE PROCEDURE [dbo].[PrescriptEmailPickNotification] (
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

DECLARE @Document varchar(30)
	SELECT @Document = Value FROM @input WHERE Name = 'Document'


DECLARE @subject nvarchar(max)
DECLARE @templateName nvarchar(max)
DECLARE @templateParameters nvarchar(max)
DECLARE @toEmailAddresses nvarchar(max)
DECLARE @ccEmailAddresses nvarchar(max)
DECLARE @bccEmailAddresses nvarchar(max)
DECLARE @reportAttachments nvarchar(max)
DECLARE @excelAttachments nvarchar(max)
DECLARE @fileAttachments nvarchar(max)
DECLARE @responseCode int
DECLARE @responseJSON nvarchar(max)


IF @stepInput = 'NOT VALID'
	SELECT * FROM EmailTemplatePickedLines

IF (@stepInput = 'Yes')
	BEGIN
	IF EXISTS(SELECT * FROM Document WHERE Number = @Document AND Type = 'ORDER')
		BEGIN
			SET @subject = CONCAT(@Document, ' picked.')                                                                         
			SET @templateName = 'PickingNotification'   
			SET @templateParameters = dbo.email_AddTemplateParameter(@templateParameters, 'documentNumber', @Document) 
			SET @toEmailAddresses = (SELECT Value FROM SystemStaticData WHERE [Key] = 'PickingConfirmation')                                    

			EXECUTE [dbo].[clr_TemplateEmail] 
			   @subject
			  ,@templateName
			  ,@templateParameters
			  ,@toEmailAddresses
			  ,@ccEmailAddresses
			  ,@bccEmailAddresses
			  ,@reportAttachments
			  ,@excelAttachments
			  ,@fileAttachments
			  ,@responseCode OUTPUT
			  ,@responseJSON OUTPUT

			IF (@responseCode = 200)
				SELECT @valid = 1, @message = @responseJSON
			ELSE
				SELECT @valid = 0, @message = @responseJSON
		END
	ELSE
		BEGIN
			SELECT @valid = 0, @message = 'Document does not exist'
		END

	END





	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
