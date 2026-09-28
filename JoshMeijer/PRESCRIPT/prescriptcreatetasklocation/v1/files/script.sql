CREATE PROCEDURE [dbo].[PrescriptCreateTaskLocation] (
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
DECLARE @LocationID bigint
IF ISNULL(@stepInput,'') != ''
BEGIN
	SELECT @LocationID = ID
	FROM Location
	WHERE Barcode = @stepInput
	IF ISNULL(@LocationID,0) != 0
	BEGIN 
		SELECT @valid = 1
		SELECT @message = ''
	END 
	ELSE 
	BEGIN 
		SELECT @valid = 0
		SELECT @message = CONCAT(@stepInput,' is not a valid Location.')
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
