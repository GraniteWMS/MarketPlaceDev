CREATE PROCEDURE [dbo].[Prescript_Example_SendTemplateEmailWithParameters] (
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
SET @templateName = 'PickingNotification'                                                          
SET @templateParameters = dbo.email_AddTemplateParameter(@templateParameters, 'documentNumber', 'SO000123') 
SET @templateParameters = dbo.email_AddTemplateParameter(@templateParameters, 'customerName', 'John Smith') 
SET @subject = 'Example template email'        
SET @toEmailAddresses = 'email1@gmail.com;email2@gmail.com'   
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
IF @responseCode = 200
BEGIN
	SELECT @valid = 1
	SELECT @message = 'Mail queued successfully'
END	
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = @responseJSON
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
