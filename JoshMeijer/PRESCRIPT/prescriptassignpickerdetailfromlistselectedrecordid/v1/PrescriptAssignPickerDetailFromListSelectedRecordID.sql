CREATE PROCEDURE [dbo].[PrescriptAssignPickerDetailFromListSelectedRecordID] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE
	  @valid						bit 
	, @message						varchar(MAX) 
	, @stepInput					varchar(MAX) 
	, @user							varchar(50) 
	, @type							varchar(50)
	, @document						varchar(50)
	, @documentID					bigint 
	, @assignTo						varchar(50)
	, @selectedIDs					varchar(max) 
	, @optionalFieldID				bigint 
SELECT @valid			= 1 
SELECT @stepInput		= Value FROM @input WHERE Name = 'StepInput'	
SELECT @user			= Value FROM @input WHERE Name = 'User'         
SELECT @type			= Value FROM @input WHERE Name = 'Type'			
SELECT @document		= Value FROM @input WHERE Name = 'Document'		
SELECT @assignTo		= Value FROM @input WHERE Name = 'AssignTo'		
BEGIN TRY 
	SELECT @documentID = ID FROM Document WHERE Number = @Document 
	SELECT @optionalFieldID = ID FROM OptionalFields WHERE AppliesTo = 'DOCUMENTDETAIL' AND Name = 'AssignedTo' 
	DECLARE @DocumentDetailList as TABLE 
		(ID bigint IDENTITY(1,1)
		,DocumentDetailID bigint
		,DocumentDetailVersion int 
		,DocumentDetailAssignedPicker varchar(50)
		)
	INSERT INTO @DocumentDetailList
	SELECT DocumentDetail.ID
		  ,ISNULL(DocumentDetail.[Version],1)
		  ,[dbo].[FN_GetOptionalField] ('AssignedTo','DOCUMENTDETAIL',DocumentDetail.ID)
	FROM DocumentDetail 
	WHERE DocumentDetail.Document_id = @DocumentID  
	AND DocumentDetail.ID in (select Item from fn_SSRS_ParameterSplit(@stepInput,',')) 
	DECLARE @RecCount bigint = (SELECT COUNT(ID) FROM @DocumentDetailList) 
		   ,@RecCurrent bigint = 1
	IF @RecCount <= 0 
		RAISERROR('Document %s has no data for selected records ', 16, 1, @document) 
	WHILE @RecCurrent < = @RecCount 
	BEGIN 
		DECLARE 
			  @currentDetailID bigint 
			, @currentDetailVersion int 
			, @currentDetailAssignedPicker varchar(50)
		SELECT @currentDetailID = DocumentDetailID 
			  ,@currentDetailVersion = DocumentDetailVersion 
			  ,@currentDetailAssignedPicker = DocumentDetailAssignedPicker 
		FROM @DocumentDetailList 
		WHERE ID = @RecCurrent
		IF @type = 'ASSIGN'
		BEGIN 
			IF ISNULL(@currentDetailAssignedPicker,'') <> '' 
			BEGIN 
				
				UPDATE OptionalFieldValues_DocumentDetail 
				SET [Value] = @assignTo 
				WHERE OptionalField_id = @optionalFieldID 
				AND BelongsTo_id = @currentDetailID 
			END
			ELSE 
			BEGIN
				
				INSERT INTO OptionalFieldValues_DocumentDetail ([Value], OptionalField_id, BelongsTo_id)
				VALUES (@assignTo, @optionalFieldID, @currentDetailID)  
			END
			UPDATE DocumentDetail 
			SET [Version] = @currentDetailVersion + 1 
			WHERE ID = @currentDetailID 
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
					,@currentDetailID
					,@currentDetailVersion + 1
					,'SQL'
					,'DocumentDetail'
					,'UPDATE'
					,'OptionalField AssignedTo'
					,ISNULL(@currentDetailAssignedPicker,'')
					,@assignTo)
		END
		ELSE IF @type = 'UNASSIGN'
		BEGIN
			
			DELETE FROM OptionalFieldValues_DocumentDetail 
			WHERE OptionalField_id = @optionalFieldID 
			AND BelongsTo_id = @currentDetailID 
			UPDATE DocumentDetail 
			SET [Version] = @currentDetailVersion + 1 
			WHERE ID = @currentDetailID 
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
				,@currentDetailID
				,@currentDetailVersion + 1
				,'SQL'
				,'DocumentDetail'
				,'UPDATE'
				,'OptionalField AssignedTo'
				,ISNULL(@currentDetailAssignedPicker,'')
				,'')
		END
		SELECT @RecCurrent = @RecCurrent + 1 
	END
	IF @type = 'ASSIGN' 
		SELECT @message = CONCAT('Document: ',@Document,' selected lines assigned to ',@assignTo)
	ELSE 
		SELECT @message = CONCAT('Document: ',@Document,' selected lines unassigned from ',@assignTo)
END TRY 
BEGIN CATCH
	SET @valid = 0
	SET @message = 'Error: ' + ERROR_MESSAGE() 
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
