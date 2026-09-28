create PROCEDURE [dbo].[PrescriptTakeonSerialNumber] (
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
DECLARE @MasterItem varchar(50)
DECLARE @EnforceSerialNumber bit
SELECT @MasterItem = Value FROM @input WHERE Name = 'MasterItem'
SELECT @EnforceSerialNumber = EnforceSerialNumber
FROM MasterItem
WHERE Code = @MasterItem
IF (@EnforceSerialNumber = 1) AND (@stepInput = '')
BEGIN
	SELECT @valid = 0
	SELECT @message = CONCAT(@MasterItem,' must have a Serial number.')
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
