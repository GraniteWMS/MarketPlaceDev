CREATE PROCEDURE [dbo].[PrescriptAssignPickerType] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1 
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE
	  @user							varchar(50) 
	, @userID						bigint 
SELECT @valid					= 1 
SELECT @stepInput				= Value FROM @input WHERE Name = 'StepInput'			
SELECT @user					= Value FROM @input WHERE Name = 'User'					
	DELETE FROM ProcessStepLookupDynamic WHERE Process = 'ASSIGNPICKER' AND ProcessStep = 'PickerName' AND UserName = @user 
	INSERT INTO ProcessStepLookupDynamic 
			([Value]
            ,[Description]
            ,[Process]
            ,[ProcessStep]
            ,[UserName])
	SELECT U.Name
		  ,U.Name
		  ,'ASSIGNPICKER' 
		  ,'PickerName'
		  ,@user 
	FROM Users U 
	INNER JOIN UserGroup UG ON UG.ID = U.UserGroup_id AND UPPER(UG.Name) LIKE '%PICK%' 
	WHERE isActive = 1 
	ORDER BY U.Name 
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
