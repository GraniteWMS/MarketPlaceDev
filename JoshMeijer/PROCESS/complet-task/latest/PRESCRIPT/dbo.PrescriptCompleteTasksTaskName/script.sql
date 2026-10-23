CREATE PROCEDURE [dbo].[PrescriptCompleteTasksTaskName] (
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
IF EXISTS(SELECT TaskID FROM Custom_TaskList WHERE Custom_TaskList.TaskName = @stepInput 
AND Custom_TaskList.Status = 'ACTIVE' )
BEGIN
	SELECT @valid = 1
	SELECT @message = ''
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = 'Not an active task'
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
