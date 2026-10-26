CREATE PROCEDURE [dbo].[PrescriptCreateTaskConfirmation] (
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
DECLARE @TaskName varchar(50)
DECLARE @TaskDescription varchar(250)
DECLARE @LocationID bigint
DECLARE @Location varchar(50)
DECLARE @TrackingEntity varchar(50)
DECLARE @TrackingEntityID bigint
DECLARE @User varchar(50)
DECLARE @UserID bigint
DECLARE @AssignedUser varchar(50)
DECLARE @AssignedUserID bigint
SELECT @TaskName = Value FROM @input WHERE Name = 'TaskName'
SELECT @TaskDescription = Value FROM @input WHERE Name = 'TaskDescription'
SELECT @TrackingEntity  = Value FROM @input WHERE Name = 'TrackingEntity'
SELECT @Location  = Value FROM @input WHERE Name = 'Location'
SELECT @AssignedUser  = Value FROM @input WHERE Name = 'AssignedUser'
SELECT @User  = Value FROM @input WHERE Name = 'User'
SELECT @UserID = ID
FROM Users
WHERE Name = @User
SELECT @LocationID = ID
FROM Location
WHERE barcode = @Location
SELECT @TrackingEntityID = ID
FROM TrackingEntity
WHERE barcode = @TrackingEntity
SELECT @AssignedUserID = ID
FROM Users
WHERE Name = @AssignedUser
SELECT @valid = 1
SELECT @message = ''
IF @stepInput = 'Yes'
BEGIN 
	INSERT into Custom_TaskList(TaskName,TaskDescription, TrackingEntityID,LocationID,UserID,AuditUserID,AuditDate,Status)
	VALUES (@TaskName,@TaskDescription,@TrackingEntityID,@LocationID,@AssignedUserID,@UserID,GETDATE(),'ACTIVE')
	SELECT @message = 'Task created successfully'
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
