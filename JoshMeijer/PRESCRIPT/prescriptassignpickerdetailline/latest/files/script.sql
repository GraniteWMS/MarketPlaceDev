CREATE PROCEDURE [dbo].[PrescriptAssignPickerDetailLine] (
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
DECLARE @PickerName varchar(50)
DECLARE @Document varchar(50) 
DECLARE @DocumentID bigint 
DECLARE @DocumentDetailID bigint 
DECLARE @DocumentDetailVersion int
DECLARE @DocumentDetailAssignedPicker varchar(50)
DECLARE @User varchar(20)
DECLARE @OptionFieldID bigint 
SELECT @stepInput = UPPER(@stepInput)
SELECT @Type = Value FROM @input WHERE Name = 'Type'
SELECT @PickerName = Value FROM @input WHERE Name = 'PickerName'
SELECT @Document = Value FROM @input WHERE Name = 'Document'
SELECT @User = Value FROM @input WHERE Name = 'User'
SELECT @OptionFieldID = ID FROM OptionalFields WHERE AppliesTo = 'DOCUMENTDETAIL' AND Name = 'AssignedTo' 
SELECT @DocumentID = ID FROM Document WHERE Number = @Document 
SELECT @DocumentDetailID = ID
	  ,@DocumentDetailVersion = ISNULL([Version],1)
	  ,@DocumentDetailAssignedPicker = [dbo].[FN_GetOptionalField] ('AssignedTo','DOCUMENTDETAIL',DocumentDetail.ID)
FROM DocumentDetail 
WHERE Document_id = @DocumentID  
AND LineNumber = @stepInput 
IF ISNULL(@DocumentDetailID,0) != 0
BEGIN
	IF @Type = 'ASSIGN'
	BEGIN 
		IF ISNULL(@DocumentDetailAssignedPicker,'') <> '' 
		BEGIN 
			
			UPDATE OptionalFieldValues_DocumentDetail 
			SET [Value] = @PickerName 
			WHERE OptionalField_id = @OptionFieldID 
			AND BelongsTo_id = @DocumentDetailID 
		END
		ELSE 
		BEGIN
			
			INSERT INTO OptionalFieldValues_DocumentDetail ([Value], OptionalField_id, BelongsTo_id)
			VALUES (@PickerName, @OptionFieldID, @DocumentDetailID)  
		END
		UPDATE DocumentDetail 
		SET [Version] = @DocumentDetailVersion + 1 
		WHERE ID = @DocumentDetailID 
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
				,@DocumentDetailID
				,@DocumentDetailVersion + 1
				,'SQL'
				,'DocumentDetail'
				,'UPDATE'
				,'OptionalField AssignedTo'
				,ISNULL(@DocumentDetailAssignedPicker,'')
				,@PickerName)
		SELECT @message = CASE WHEN ISNULL(@DocumentDetailAssignedPicker,'') != '' 
								THEN CONCAT('Document: ',@Document,' Line: ',@stepInput,' assigned picker changed from ',@DocumentDetailAssignedPicker,' to ',@PickerName) 
								ELSE CONCAT('Document: ',@Document,' Line: ',@stepInput,' assigned to ',@PickerName)
							END
	END
	ELSE IF @Type = 'UNASSIGN'
	BEGIN
		IF @DocumentDetailAssignedPicker = @PickerName
		BEGIN
			
			DELETE FROM OptionalFieldValues_DocumentDetail 
			WHERE OptionalField_id = @OptionFieldID 
			AND BelongsTo_id = @DocumentDetailID 
			UPDATE DocumentDetail 
			SET [Version] = @DocumentDetailVersion + 1 
			WHERE ID = @DocumentDetailID 
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
				,@DocumentDetailID
				,@DocumentDetailVersion + 1
				,'SQL'
				,'DocumentDetail'
				,'UPDATE'
				,'OptionalField AssignedTo'
				,ISNULL(@DocumentDetailAssignedPicker,'')
				,'')
			SELECT @message = CONCAT('Document: ',@Document,' Line: ',@stepInput,' is no longer assigned to ',@PickerName)
		END
		ELSE
		BEGIN
			SELECT @valid = 0
			SELECT @message = CONCAT('Document: ',@Document,' Line: ',@stepInput,' is not assigned to ',@PickerName,' cannot unassign')
		END
	END
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = CONCAT('Document: ',@Document,' Line: ',@stepInput,' is not a valid') 
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
