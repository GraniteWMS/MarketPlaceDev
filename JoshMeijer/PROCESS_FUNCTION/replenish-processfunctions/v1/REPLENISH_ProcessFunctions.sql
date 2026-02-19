-- =============================================
-- Process Function Inserts
-- =============================================

DECLARE @ParentProcessId bigint = (SELECT [ID] FROM [Process] WHERE [Name] = 'REPLENISH');
DECLARE @FunctionProcessId bigint;
DECLARE @ParentProcessStepId bigint;
DECLARE @ProcessFunctionId bigint;

-- ProcessFunction 1
SET @FunctionProcessId = (SELECT [ID] FROM [Process] WHERE [Name] = 'SCRAP');
SET @ParentProcessStepId = NULL;
INSERT INTO [ProcessFunction] ([Process_id],[ParentProcessStep_id],[ParentProcess_id],[IsActive],[ProcessFunctionMenuIndex],[FinalStepBehavior],[ProcessLayoutOverride])
VALUES (@FunctionProcessId,NULL,@ParentProcessId,1,0,'CLOSE',NULL);
SET @ProcessFunctionId = SCOPE_IDENTITY();

