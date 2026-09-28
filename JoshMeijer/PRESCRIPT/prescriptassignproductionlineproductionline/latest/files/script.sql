CREATE PROCEDURE [dbo].[PrescriptAssignProductionLineProductionLine] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit =1
DECLARE @message varchar(MAX) = ''
DECLARE @stepInput varchar(MAX) 
DECLARE @Batch varchar(10)
DECLARE @Week varchar(2)
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @CurrentJob varchar(30) 
SELECT TOP 1 
    @CurrentJob = CONCAT(prefix ,CONVERT(varchar(10),job_numbers.numeric_suffix + 1))
FROM 
    (
        SELECT 
            CurrentJob,
            LEFT(CurrentJob, PATINDEX('%[0-9]%', CurrentJob) - 1) AS prefix,
            CONVERT(int,SUBSTRING(CurrentJob, PATINDEX('%[0-9]%', CurrentJob), LEN(CurrentJob))) AS numeric_suffix
        FROM 
            Custom_ProductionLineAssignments
    ) AS job_numbers
	ORDER by numeric_suffix DESC
	SELECT @message = 'Next Job is:' + @CurrentJob
	INSERT INTO @Output
	SELECT 'Job', @CurrentJob
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
