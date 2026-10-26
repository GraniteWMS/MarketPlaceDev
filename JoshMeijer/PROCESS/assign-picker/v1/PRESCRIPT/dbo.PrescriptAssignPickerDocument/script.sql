CREATE PROCEDURE [dbo].[PrescriptAssignPickerDocument] (
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
DECLARE @Type varchar(10)
DECLARE @PickerName varchar(20)
DECLARE @DocumentID bigint
DECLARE @DocumentType varchar(50)
DECLARE @DocumentAssignedPicker varchar(20)
DECLARE @DocumentVersion int
DECLARE @User varchar(20)
SELECT @stepInput = UPPER(@stepInput)
SELECT @Type = Value FROM @input WHERE Name = 'Type'
SELECT @PickerName = Value FROM @input WHERE Name = 'PickerName'
SELECT @User = Value FROM @input WHERE Name = 'User'
SELECT @DocumentID = ID, @DocumentType = [Type], @DocumentAssignedPicker = AssignedTo, @DocumentVersion = [Version]
FROM Document
WHERE Number = @stepInput
IF ISNULL(@DocumentID,0) != 0
BEGIN
	IF @DocumentType IN ('ORDER','PICKSLIP') 
	BEGIN
		IF @Type = 'ASSIGN'
		BEGIN
			UPDATE Document
			SET AssignedTo = @PickerName,
				[Version] = @DocumentVersion + 1
			WHERE ID = @DocumentID
			INSERT INTO [dbo].[Audit]
				   ([AuditDate]
				   ,[AuditTime]
				   ,[User]
				   ,[RecordID]
				   ,[RecordVersion]
				   ,[Application]
				   ,[TableName]
				   ,[ChangeType]
				   ,[ColumnName]
				   ,[PreviousValue]
				   ,[NewValue])
			 VALUES
				   (CONVERT(date,GETDATE())
				   ,CONVERT(time,GETDATE())
				   ,@User
				   ,@DocumentID
				   ,@DocumentVersion + 1
				   ,'SQL'
				   ,'Document'
				   ,'UPDATE'
				   ,'AssignedTo'
				   ,ISNULL(@DocumentAssignedPicker,'')
				   ,@PickerName)
			SELECT @message = CASE WHEN ISNULL(@DocumentAssignedPicker,'') != '' 
								   THEN CONCAT(@stepInput,' assigned picker changed from ',@DocumentAssignedPicker,' to ',@PickerName) 
								   ELSE CONCAT(@stepInput,' assigned to ',@PickerName)
							  END
		END
		ELSE IF @Type = 'UNASSIGN'
		BEGIN
			IF @DocumentAssignedPicker = @PickerName
			BEGIN
				UPDATE Document
				SET AssignedTo = NULL,
					[Version] = @DocumentVersion + 1
				WHERE ID = @DocumentID
				INSERT INTO [dbo].[Audit]
				   ([AuditDate]
				   ,[AuditTime]
				   ,[User]
				   ,[RecordID]
				   ,[RecordVersion]
				   ,[Application]
				   ,[TableName]
				   ,[ChangeType]
				   ,[ColumnName]
				   ,[PreviousValue]
				   ,[NewValue])
			 VALUES
				   (CONVERT(date,GETDATE())
				   ,CONVERT(time,GETDATE())
				   ,@User
				   ,@DocumentID
				   ,@DocumentVersion + 1
				   ,'SQL'
				   ,'Document'
				   ,'UPDATE'
				   ,'AssignedTo'
				   ,ISNULL(@DocumentAssignedPicker,'')
				   ,'')
				SELECT @message = CONCAT(@PickerName,' is no longer assigned to ',@stepInput)
			END
			ELSE
			BEGIN
				SELECT @valid = 0
				SELECT @message = CONCAT(@stepInput,' is not assigned to ',@PickerName)
			END
		END
	END
	ELSE 
	BEGIN
		SELECT @valid = 0
		SELECT @message = CONCAT('Document ',@stepInput,' is not a PICKSLIP or ORDER')
	END
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = CONCAT('Document ',@stepInput,' is not a valid document') 
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
