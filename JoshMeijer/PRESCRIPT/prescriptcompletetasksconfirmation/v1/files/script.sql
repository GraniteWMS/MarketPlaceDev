CREATE PROCEDURE [dbo].[PrescriptCompleteTasksConfirmation] (
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
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @taskname varchar(50)
SELECT @taskname = Value FROM @input WHERE Name = 'TaskName'
DECLARE @UserID bigint
DECLARE @User varchar(50)
SELECT @User= Value FROM @input WHERE Name = 'User'
SELECT @UserID = ID
FROM Users
WHERE Name = @User
IF @stepInput = 'Yes'
BEGIN
	UPDATE Custom_TaskList
	set Status = 'COMPLETE',
	AuditDate = GETDATE(),
	AuditUserID = @userID
	WHERE TaskName = @taskname
	AND Status = 'ACTIVE'
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
