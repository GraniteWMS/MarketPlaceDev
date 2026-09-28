CREATE PROCEDURE [dbo].[Prescript3PL_LOADOUTDOC_Document] (
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
DECLARE @user varchar(50) =(SELECT Value FROM @input WHERE Name = 'User')
DECLARE @user_id bigint
DECLARE @Principle varchar(30) = (SELECT Value FROM @input WHERE Name = 'Principle')
DECLARE @Document varchar(50) = @stepInput
DECLARE @Document_id bigint
DECLARE @ExpectedDate datetime
IF @Document = 'NEWDOC'
BEGIN
	SELECT @Document = isnull(@Principle,'') + CONVERT(varchar(6),NextBarcode) FROM BarcodeMaster WHERE Name = 'DOCUMENTORDER'
	SELECT @Document_id = ID FROM Document WHERE Number = @Document
	INSERT INTO @Output
	SELECT 'Document', @Document
	SELECT @stepInput = @Document
	SELECT @message = 'Document number assigned:' +  @Document
END
SELECT @ExpectedDate = ExpectedDate, @Document_id = ID FROM Document WHERE Number = @Document
IF isnull(@Document_id,0) = 0
BEGIN
	SELECT @ExpectedDate = getdate()
	SELECT @message = 'Document DOES NOT exist'
END
INSERT INTO @Output
SELECT 'ExpectedDate', @ExpectedDate
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
