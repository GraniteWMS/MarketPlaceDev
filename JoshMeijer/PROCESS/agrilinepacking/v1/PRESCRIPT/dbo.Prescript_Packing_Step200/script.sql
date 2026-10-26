CREATE PROCEDURE [dbo].[Prescript_Packing_Step200] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
)
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @BoxNumber varchar(30) = (SELECT Value FROM @input WHERE Name = 'CarryingEntity')
DECLARE @MasterItem varchar(50) 
	SELECT @MasterItem = Value FROM @input WHERE Name = 'MasterItem'
DECLARE @MasterItemWeight Decimal(19,3)
BEGIN TRY
	SELECT @MasterItemWeight = [UnitWeight] FROM MasterItem WHERE Code = @MasterItem
	UPDATE dbo.CarryingEntity
	SET [Weight] = 0
	WHERE dbo.CarryingEntity.Barcode = @BoxNumber AND ISNULL([Weight],0) = 0
	UPDATE dbo.CarryingEntity
	SET [Weight] += @MasterItemWeight
	WHERE dbo.CarryingEntity.Barcode = @BoxNumber
	
END TRY
BEGIN CATCH
	SELECT @valid = 0
	,@message = ERROR_MESSAGE()
END CATCH
OutputResults:
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT Name, Value FROM @Output
