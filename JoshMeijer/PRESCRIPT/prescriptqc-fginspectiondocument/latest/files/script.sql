CREATE PROCEDURE [dbo].[PrescriptQC_FGInspectionDocument] (
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
DECLARE @user varchar(30) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @stepInput varchar(MAX) = (SELECT UPPER(Value) FROM @input WHERE Name = 'StepInput') 
DECLARE @Document varchar(50) = RTRIM(@stepInput)
DECLARE @Document_id BIGINT
SELECT @Document_id = ID FROM Document WHERE Number = @Document
IF @Document_id >0
BEGIN
	
	INSERT INTO custom_DocumentTrackingLog (Document,[Version],TrackingStatus,[User],ActivityDate,Comment)
	SELECT @Document,1,'Start Inspection Capture',@user,getdate(),'Starting QC_FGInspection Process'
	SELECT @message = 'Started Inspection process for MO Document:' + isnull(@Document,'')
	SELECT @valid = 1
END
ELSE
BEGIN
	SELECT @message = 'The Entered Docuent:' + isnull(@Document,'') + ' is not found, or is not released'
	SELECT @valid = 0
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
