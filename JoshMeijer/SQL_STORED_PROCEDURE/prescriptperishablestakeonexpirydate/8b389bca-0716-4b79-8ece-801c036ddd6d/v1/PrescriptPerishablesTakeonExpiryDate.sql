CREATE PROCEDURE [dbo].[PrescriptPerishablesTakeonExpiryDate] (
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
DECLARE @EnforceExpiry bit

SELECT @MasterItem = [Value] FROM @input WHERE [Name] = 'MasterItem'

IF EXISTS(SELECT ID FROM MasterItem WHERE Code = @MasterItem)
BEGIN
	SELECT @EnforceExpiry = ISNULL(EnforceExpiryDate, 0) 
	FROM MasterItem 
	WHERE Code = @MasterItem
END
ELSE IF EXISTS(SELECT ID FROM MasterItem WHERE FormattedCode = @MasterItem)
BEGIN
	SELECT @EnforceExpiry = ISNULL(EnforceExpiryDate, 0) 
	FROM MasterItem 
	WHERE FormattedCode = @MasterItem
END

IF @EnforceExpiry = 1 AND ISNULL(@stepInput, '') = ''
BEGIN
	SELECT @valid = 0
	SELECT @message = 'You must supply an expiry date for this item'
END
ELSE
BEGIN
	SELECT @valid = 1
END





	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
