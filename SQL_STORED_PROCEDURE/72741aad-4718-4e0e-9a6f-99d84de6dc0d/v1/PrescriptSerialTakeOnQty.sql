CREATE PROCEDURE [dbo].[PrescriptSerialTakeOnQty] (
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

IF ISNUMERIC(@stepInput) = 0
BEGIN
    SELECT @valid = 0
    SELECT @message = CONCAT(@stepInput, ' is not a valid qty')
END
ELSE
BEGIN
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

    IF @EnforceSerial = 1 AND CONVERT(decimal(19,4), @stepInput) <> 1
    BEGIN
        SELECT @valid = 0
        SELECT @message = 'Serialised items must have a qty of 1'
    END
END





	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
