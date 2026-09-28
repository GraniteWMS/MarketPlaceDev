/*------------------------------------------------------------------
  Site settings
------------------------------------------------------------------*/
DECLARE @FunctionProcess     varchar(50)  = N'STOCKTAKE OVERRIDE';  -- process called as the function
DECLARE @ParentProcess       varchar(50)  = N'STOCKTAKE';           -- process the function is mounted on
DECLARE @ParentStepName      varchar(25)  = N'TrackingEntity';      -- step the function button appears on
DECLARE @AuditUser           varchar(20)  = N'0';

DECLARE @MenuIndex           int          = 1;
DECLARE @FinalStepBehavior   varchar(50)  = N'CLOSE';   -- CLOSE returns to the parent step
DECLARE @ProcessLayoutOverride varchar(50) = NULL;
DECLARE @IsActive            bit          = 1;

/*------------------------------------------------------------------
  Resolve the IDs
------------------------------------------------------------------*/
DECLARE @ProcessId           bigint;
DECLARE @ParentProcessStepId bigint;
DECLARE @ProcessFunctionId   bigint;

SELECT @ProcessId = p.ID
FROM dbo.Process AS p
WHERE p.[Name] = @FunctionProcess;

SELECT @ParentProcessStepId = ps.ID
FROM dbo.ProcessStep AS ps
WHERE ps.[Process] = @ParentProcess
  AND ps.[Name]    = @ParentStepName;

/*------------------------------------------------------------------
  Create the process function and its value mappings
------------------------------------------------------------------*/
BEGIN TRY
    BEGIN TRANSACTION;

    SELECT @ProcessFunctionId = pf.ID
    FROM dbo.ProcessFunction AS pf
    WHERE pf.Process_id           = @ProcessId
      AND pf.ParentProcessStep_id = @ParentProcessStepId;

    IF @ProcessFunctionId IS NULL
    BEGIN
        INSERT dbo.ProcessFunction
        (
            Process_id,
            ParentProcessStep_id,
            ParentProcess_id,
            IsActive,
            ProcessFunctionMenuIndex,
            FinalStepBehavior,
            ProcessLayoutOverride,
            AuditUser,
            AuditDate,
            [Version]
        )
        VALUES
        (
            @ProcessId,
            @ParentProcessStepId,
            NULL,                      -- mounted on one step, not the whole process
            @IsActive,
            @MenuIndex,
            @FinalStepBehavior,
            @ProcessLayoutOverride,
            @AuditUser,
            GETDATE(),
            1
        );
    END

    /*--------------------------------------------------------------
      Parent step -> function step value mappings
    --------------------------------------------------------------*/
    DECLARE @Mapping TABLE
    (
        ParentProcessStep varchar(25) NOT NULL,
        FunctionStep      varchar(25) NOT NULL
    );

    ,
           (N'Count',    N'Count'),
           (N'Location', N'Location');

    INSERT dbo.ProcessFunctionMapping (ProcessFunction_id, ParentProcessStep, FunctionStep)
    SELECT @ProcessFunctionId, m.ParentProcessStep, m.FunctionStep
    FROM @Mapping AS m
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.ProcessFunctionMapping AS pfm
        WHERE pfm.ProcessFunction_id = @ProcessFunctionId
          AND pfm.ParentProcessStep  = m.ParentProcessStep
          AND pfm.FunctionStep       = m.FunctionStep
    );

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH