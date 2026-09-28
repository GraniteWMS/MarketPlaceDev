CREATE PROCEDURE [dbo].[PrescriptAssignProductionLineConfirmation] (
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
DECLARE @CurrentJob varchar(30)
DECLARE @MasterItemCode varchar(50)
DECLARE @ProductionLine varchar(50)
DECLARE @PreformMasterItemCode varchar(50)
DECLARE @Batch varchar(10)
DECLARE @User varchar(50)
DECLARE @PalletsPerBatch varchar(4)
DECLARE @BottlesPerPallet varchar(4)
SELECT @CurrentJob = UPPER(Value) FROM @input WHERE Name = 'Job'
SELECT @MasterItemCode = UPPER(Value) FROM @input WHERE Name = 'MasterItem'
SELECT @ProductionLine = UPPER(Value) FROM @input WHERE Name = 'ProductionLine'
SELECT @PreformMasterItemCode = UPPER(Value) FROM @input WHERE Name = 'PreformMasterItem'
SELECT @Batch = UPPER(Value) FROM @input WHERE Name = 'Batch'
SELECT @PalletsPerBatch = Value FROM @input WHERE Name = 'PalletsPerBatch'
SELECT @BottlesPerPallet = Value FROM @input WHERE Name = 'BottlesPerPallet'
SELECT @User = UPPER(Value) FROM @input WHERE Name = 'User'
IF @stepInput = 'yes'
BEGIN
	UPDATE Custom_ProductionLineAssignments
	SET IsActive = 0
	WHERE IsActive = 1
	  AND ProductionLine = @ProductionLine
	INSERT INTO Custom_ProductionLineAssignments (ProductionLine, MasterItem, IsActive, AssignedDate, [User], PreformMasterItem,CurrentBatch, PalletsPerBatch, BottlesPerPallet,CurrentJob)
	VALUES (@ProductionLine, @MasterItemCode, 1, GETDATE(), @User,@PreformMasterItemCode, @Batch, @PalletsPerBatch, CONVERT(int,@BottlesPerPallet), @CurrentJob)
	SELECT @valid = 1
	SELECT @message = CONCAT('Item code ',@MasterItemCode,' assigned to Production Line ',@ProductionLine)
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
