CREATE PROCEDURE [dbo].[PrescriptAssignPickerDetailDocument] (
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
	IF @DocumentType NOT IN ('ORDER','PICKSLIP') 
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
