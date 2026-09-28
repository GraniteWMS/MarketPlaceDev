CREATE PROCEDURE [dbo].[PrescriptAssignProductionLineMasterItem] (
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
DECLARE @Batch varchar(10)
DECLARE @CurrentJob varchar(30) = (SELECT Value from @input WHERE Name = 'Job')
DECLARE @ProductionLine varchar(20) = (SELECT Value from @input WHERE Name = 'ProductionLine')
DECLARE @Week varchar(2)
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @QtyperPallet varchar(10)
DECLARE @QtyperPalletFieldID bigint = 2
DECLARE @MasterItemID bigint
SELECT @MasterItemID = ID
FROM MasterItem
WHERE Code = @stepInput
IF ISNULL(@MasterItemID,0) <> 0
BEGIN
	SELECT @Week = CASE WHEN DATEPART(WEEK,getdate()) <10 THEN CONCAT('0',CONVERT(varchar(2),DATEPART(WEEK,getdate()))) ELSE CONVERT(varchar(2),DATEPART(WEEK,getdate())) END
	
	SELECT @Batch = (SELECT CONCAT(CONVERT(varchar(2),getdate(),12),@Week,RIGHT(@ProductionLine,1),'1'))
	SELECT @QtyperPallet = Value FROM OptionalFieldValues_MasterItem WHERE BelongsTo_id = @MasterItemID AND OptionalField_id = @QtyperPalletFieldID
	SELECT @valid = 1
	SELECT @message = ''
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = CONCAT('Item Code ',UPPER(@stepInput),' is not a valid item code.')
END
	INSERT INTO @Output
	SELECT 'BottlesPerPallet',@QtyperPallet
	INSERT INTO @Output
	SELECT 'Batch', @Batch
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
