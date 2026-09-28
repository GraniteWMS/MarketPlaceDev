CREATE PROCEDURE [dbo].[PrescriptCreateTaskTrackingEntity] (
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
DECLARE @TrackingEntityID bigint
IF ISNULL(@stepInput,'') != ''
BEGIN
	SELECT @TrackingEntityID = ID
	FROM TrackingEntity
	WHERE Barcode = @stepInput
	IF ISNULL(@TrackingEntityID,0) != 0
	BEGIN 
		SELECT @valid = 1
		SELECT @message = ''
	END 
	ELSE 
	BEGIN 
		SELECT @valid = 0
		SELECT @message = CONCAT(@stepInput,' is not a valid Tracking Entity.')
	END
END
ELSE
BEGIN
	SELECT @valid = 1
	SELECT @message = ''
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
