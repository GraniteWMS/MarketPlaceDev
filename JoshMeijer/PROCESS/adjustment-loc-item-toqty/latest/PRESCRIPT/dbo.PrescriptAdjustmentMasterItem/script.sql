CREATE PROCEDURE [dbo].[PrescriptAdjustmentMasterItem] (
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
DECLARE @MasterItemCode varchar(250)
DECLARE @MasterItemID bigint
	
	IF EXISTS(SELECT ID FROM MasterItem WHERE Code = @stepInput or FormattedCode = @stepInput)
	BEGIN
		SELECT @MasterItemCode = @stepInput
		SELECT @valid = 1
		SELECT @message = 'Item is:' + @MasterItemCode
		SELECT @stepInput = @MasterItemCode
	END
	ELSE
		IF EXISTS(SELECT ID FROM MasterItemAlias_View WHERE Code = @stepInput)
		BEGIN
			SELECT @MasterItemID = MasterItem_id FROM  MasterItemAlias_View WHERE Code = @stepInput
			SELECT @MasterItemCode = Code FROM MasterItem WHERE ID = @MasterItemID
			SELECT @valid = 1
			SELECT @message = 'Item is:' + @MasterItemCode
			SELECT @stepInput = @MasterItemCode
		END
		ELSE
		BEGIN
			SELECT @valid = 0
			SELECT @message = 'The scanned code is unknown - it is not a registered UPC, an Item Code or a Tracking Barcode'
		END 
	
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
