CREATE PROCEDURE [dbo].[PreScript_LookupMasterItem_LookUpValue] (
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
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @userName varchar(40)
DECLARE @Type varchar(40)
SELECT @userName = Value FROM @input WHERE Name = 'User'
SELECT @Type = Value FROM @input WHERE Name = 'Type'
IF @type = 'MasterItem'
BEGIN
	IF EXISTS ( SELECT 1 FROM MasterItem WHERE Code = @stepInput)
	BEGIN
		INSERT INTO @Output
		SELECT 'LookupValue', @stepInput
	
		SELECT @valid = 1
		SELECT @message = ''
	END
	ELSE
	BEGIN
		SELECT @valid = 0
		SELECT @message = 'Invalid MasterItem Code'
	END
END
IF @type = 'Inventory'
BEGIN
	IF EXISTS ( SELECT 1 FROM TrackingEntity WHERE Barcode = @stepInput)
	BEGIN	
		SELECT @valid = 1
		SELECT @message = ''
	END
	ELSE
	BEGIN
		SELECT @valid = 0
		SELECT @message = 'Invalid TrackingBarcode Number'
	END
END
IF @type = 'Batch'
BEGIN
	IF EXISTS ( SELECT 1 FROM TrackingEntity WHERE Batch = @stepInput)
	BEGIN	
		SELECT @valid = 1
		SELECT @message = ''
	END
	ELSE
	BEGIN
		SELECT @valid = 0
		SELECT @message = 'Batch Number does not exist'
	END
END
IF @type = 'Location'
BEGIN
	IF EXISTS ( SELECT 1 FROM Location WHERE Barcode = @stepInput)
	BEGIN	
		SELECT @valid = 1
		SELECT @message = ''
	END
	ELSE
	BEGIN
		SELECT @valid = 0
		SELECT @message = 'Invalid Location Barcode'
	END
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
