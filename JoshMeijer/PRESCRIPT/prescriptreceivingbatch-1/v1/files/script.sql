CREATE PROCEDURE [dbo].[PrescriptReceivingBatch] (
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
DECLARE @EnforceBatch bit = 0
SELECT @MasterItem = [Value]
FROM @input
WHERE [Name] = 'MasterItem'
SELECT TOP 1
       @EnforceBatch = ISNULL(MI.EnforceBatchNumber, 0)
FROM MasterItem MI
WHERE MI.Code = @MasterItem
   OR MI.FormattedCode = @MasterItem
ORDER BY CASE WHEN MI.Code = @MasterItem THEN 1 ELSE 2 END
IF @EnforceBatch = 1
   AND ISNULL(@stepInput, '') = ''
BEGIN
    SELECT @valid = 0
    SELECT @message = 'You must supply a batch number for this item'
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
