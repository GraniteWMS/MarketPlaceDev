CREATE PROCEDURE [dbo].[PrescriptAddEANBarcodeMasterItem] (
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
DECLARE @MasterItemID bigint = 0
IF EXISTS (SELECT 1 FROM MasterItem WHERE Code = @stepInput)
BEGIN
	SELECT @stepInput = Code, @MasterItemID = ID FROM MasterItem WHERE Code = @stepInput
	IF NOT EXISTS (SELECT *	FROM MasterItemAlias_View WHERE MasterItem_id = @MasterItemID)
	BEGIN
		SELECT @valid = 1
		SELECT @message = ''
	END
	ELSE 
	BEGIN
		SELECT @valid = 0
		SELECT @message = 'A barcode already exists against this item'
	END	
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = 'Please enter a valid MasterItem'
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
