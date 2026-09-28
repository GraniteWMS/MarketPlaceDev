CREATE PROCEDURE  [dbo].[PrescriptPickingPickMethod] (
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
DECLARE @User varchar(50) =  (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @stepInput varchar(MAX)  = (SELECT Value FROM @input WHERE Name = 'StepInput' )
DECLARE @Document varchar(50)
DECLARE @SelectionTimeDifferenceMINUTES int = 15	


DELETE FROM ProcessStepLookupDynamic WHERE UserName = @User


IF (@StepInput = 'ENTERDOC') 
BEGIN

	SELECT @Document = ''
	DELETE FROM ProcessStepLookupDynamic WHERE UserName = @User
	SELECT @message = ''
	SELECT @valid = 1
END


IF (@StepInput = 'NEXTDOC')	
BEGIN
	SELECT TOP 1 @Document  = Number FROM Document 
	WHERE  isActive = 1  and [Type] = 'ORDER'
	ORDER BY Priority, ExpectedDate, CreateDate

	SELECT @message = ''
	SELECT @valid = 1

END


IF (@StepInput = 'SELECTDOC') 
BEGIN
	SELECT @Document = ''
	INSERT INTO ProcessStepLookupDynamic (Value, Description, Process, ProcessStep, UserName)
	SELECT Number, Number + ' ' + TradingPartnerDescription, 'PICKING', 'Document', @User
	FROM Document
	WHERE Status = 'RELEASED' and isActive = 1 and [Type] = 'ORDER'
	AND Number NOT IN	
	
	(SELECT Number FROM [Transaction] INNER JOIN Document 
	ON [Transaction].Document_id = Document.ID
	WHERE [Transaction].Type = 'PICKING' 
	AND DATEDIFF(MINUTE,[Transaction].Date, getdate())  < @SelectionTimeDifferenceMINUTES )
	ORDER BY Priority, ExpectedDate, CreateDate
	

	SELECT @message = ''
	SELECT @valid = 1
END


IF (@StepInput = 'ASSIGNEDDOC')
BEGIN
	SELECT @Document = ''
	INSERT INTO ProcessStepLookupDynamic (Value, Description, Process, ProcessStep, UserName)
	SELECT Number, Number + ' ' + TradingPartnerDescription, 'PICKING', 'Document', @User
	FROM Document
	WHERE Status = 'RELEASED' and isActive = 1 and CHARINDEX(@User,AssignedTo,1) > 0		
	ORDER BY Priority, ExpectedDate, CreateDate
	
	SELECT @message = ''
	SELECT @valid = 1
END


INSERT INTO @Output
SELECT 'Document', @Document

INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput

SELECT * FROM @Output


