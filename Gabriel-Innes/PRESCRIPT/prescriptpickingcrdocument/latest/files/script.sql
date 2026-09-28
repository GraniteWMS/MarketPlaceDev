CREATE PROCEDURE [dbo].[PrescriptPickingCRDocument] (
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
DECLARE @DocumentNumber varchar(30)
	SELECT @DocumentNumber = @stepInput
DECLARE @DocumentId bigint 
	SELECT @DocumentId = ID FROM Document WHERE Number = @DocumentNumber
DECLARE @ERPLocation varchar(30) = (SELECT ERPLocation FROM Document WHERE Number = @DocumentNumber)
IF NOT EXISTS(SELECT ID FROM Document WHERE Number = @DocumentNumber AND Status in ('RELEASED', 'ENTERED') AND Type = 'ORDER')
BEGIN
	SELECT @valid = 0                  
	SELECT @message = 'Document ' + @DocumentNumber + ' does not exist.'  
END
ELSE IF (@DocumentNumber NOT LIKE 'CR-%')
BEGIN 
	SELECT @valid = 0, @message = 'Not a credit return document.'
END
ELSE
BEGIN
				
EXEC FIFOPickingReturns
		@DocumentID = @DocumentId,
		@ERPLocation = @ERPLocation
				
	SELECT @valid = 1                  
	SELECT @message = ''  
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
