-- =============================================
-- Process Function Inserts
-- =============================================

DECLARE @ParentProcessId bigint = (SELECT [ID] FROM [Process] WHERE [Name] = 'ADJUSTMENT');
DECLARE @FunctionProcessId bigint;
DECLARE @ParentProcessStepId bigint;
DECLARE @ProcessFunctionId bigint;

-- ProcessFunction 2
SET @FunctionProcessId = (SELECT [ID] FROM [Process] WHERE [Name] = 'SCRAP');
SET @ParentProcessStepId = (SELECT [ID] FROM [ProcessStep] WHERE [Process] = 'ADJUSTMENT' AND [Name] = 'TrackingEntity');
INSERT INTO [ProcessFunction] ([Process_id],[ParentProcessStep_id],[ParentProcess_id],[IsActive],[ProcessFunctionMenuIndex],[FinalStepBehavior],[ProcessLayoutOverride])
VALUES (@FunctionProcessId,@ParentProcessStepId,NULL,1,0,'CLOSE',NULL);
SET @ProcessFunctionId = SCOPE_IDENTITY();

