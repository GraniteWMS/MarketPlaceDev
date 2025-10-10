CREATE PROCEDURE [dbo].[PrescriptSerialReceivingSerialNumber] (
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
DECLARE @EnforceSerial bit

SELECT @MasterItem = [Value] FROM @input WHERE [Name] = 'MasterItem'

IF EXISTS(SELECT ID FROM MasterItem WHERE Code = @MasterItem)
BEGIN
	SELECT @EnforceSerial = ISNULL(EnforceSerialNumber, 0) 
	FROM MasterItem 
	WHERE Code = @MasterItem
END
ELSE IF EXISTS(SELECT ID FROM MasterItem WHERE FormattedCode = @MasterItem)
BEGIN
	SELECT @EnforceSerial = ISNULL(EnforceSerialNumber, 0) 
	FROM MasterItem 
	WHERE FormattedCode = @MasterItem
END

IF @EnforceSerial = 1 AND ISNULL(@stepInput, '') = ''
BEGIN
	SELECT @valid = 0
	SELECT @message = 'You must supply an serial number for this item'
END
ELSE
BEGIN
    IF @EnforceSerial = 1
    BEGIN
        INSERT INTO @Output
        SELECT 'Qty', '1'
    END

	SELECT @valid = 1
END





	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
