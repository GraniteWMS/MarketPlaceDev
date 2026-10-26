CREATE PROCEDURE [dbo].[PrescriptDynamicReversalDocument] (
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
DECLARE @location varchar(50)
DECLARE @user varchar(50)
SELECT @user = Value FROM @input WHERE Name = 'User'         
BEGIN TRY
	
	IF EXISTS(SELECT 1 FROM Document WHERE Number = @stepInput)
		SELECT 
		@valid = 1, 
		@message = 'Document valid'
	ELSE
		SELECT 
		@valid = 0, 
		@message = 'Document Not Found'
END TRY
BEGIN CATCH
	SELECT @Message = ERROR_MESSAGE()
	SELECt @valid = 0
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
