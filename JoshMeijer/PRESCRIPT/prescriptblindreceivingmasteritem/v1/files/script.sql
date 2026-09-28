CREATE PROCEDURE [dbo].[PrescriptBlindReceivingMasterItem] (
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
DECLARE @MasterItem_Identifier varchar(40)
SELECT @MasterItem_Identifier = @stepInput
IF EXISTS(SELECT ID FROM MasterItem WHERE Code = @MasterItem_Identifier AND isActive = 1)
BEGIN
	SELECT @valid = 1
END
ELSE IF EXISTS(SELECT ID FROM MasterItemAlias WHERE Code = @MasterItem_Identifier AND IsActive = 1)
BEGIN
	DECLARE @MasterItem_id bigint
	DECLARE @MasterItem_Code varchar(40)
	SELECT @MasterItem_id = MasterItem_id FROM MasterItemAlias WHERE Code = @MasterItem_Identifier AND isActive = 1
	SELECT @MasterItem_Code = Code FROM MasterItem WHERE ID = @MasterItem_id
	SELECT @stepInput = @MasterItem_Code
	SELECT @valid = 1
	SELECT @message = CONCAT('MasterItem Code is ', @MasterItem_Code)
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = 'Enter a valid MasterItem Code or Alias'
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
