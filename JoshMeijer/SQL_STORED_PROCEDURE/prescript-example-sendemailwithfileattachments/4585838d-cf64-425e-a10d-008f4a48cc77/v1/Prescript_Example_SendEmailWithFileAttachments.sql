CREATE PROCEDURE [dbo].[Prescript_Example_SendEmailWithFileAttachments] (
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
DECLARE @body nvarchar(max)
DECLARE @toEmailAddresses nvarchar(max)
DECLARE @ccEmailAddresses nvarchar(max)
DECLARE @bccEmailAddresses nvarchar(max)
DECLARE @reportAttachments nvarchar(max)
DECLARE @excelAttachments nvarchar(max)
DECLARE @fileAttachments nvarchar(max)
DECLARE @responseCode int
DECLARE @responseJSON nvarchar(max)

SET @fileAttachments = dbo.email_AddFileAttachment(@fileAttachments, 'C:\logexport.txt')
SET @fileAttachments = dbo.email_AddFileAttachment(@fileAttachments, 'C:\AnotherExport.csv')

SET @subject = 'Example mail subject' 
SET @toEmailAddresses = 'email1@gmail.com;email2@gmail.com'

EXECUTE [dbo].[clr_SimpleEmail] 
   @subject
  ,@body
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


