IF NOT EXISTS (
    SELECT 1
    FROM [dbo].[Functions]
    WHERE [Name] = N'STOCKTAKE EXPORT'
)
BEGIN
    ;
END


IF NOT EXISTS (
    SELECT 1
    FROM [dbo].[FunctionParameter]
    WHERE [FunctionName] = N'STOCKTAKE EXPORT'
      AND [Name] = N'MODE'
)
BEGIN
    ;
END


IF NOT EXISTS (
    SELECT 1
    FROM [dbo].[FunctionParameter]
    WHERE [FunctionName] = N'STOCKTAKE EXPORT'
      AND [Name] = N'LOCATION'
)
BEGIN
    ;
END


IF NOT EXISTS (
    SELECT 1
    FROM [dbo].[FunctionParameter]
    WHERE [FunctionName] = N'STOCKTAKE EXPORT'
      AND [Name] = N'SESSION'
)
BEGIN
    ;
END


IF NOT EXISTS (
    SELECT 1
    FROM [dbo].[FunctionParameterLookup]
    WHERE [FunctionName] = N'STOCKTAKE EXPORT'
      AND [ParameterName] = N'MODE'
      AND [Value] = N'ALL'
)
BEGIN
    ;
END


IF NOT EXISTS (
    SELECT 1
    FROM [dbo].[FunctionParameterLookup]
    WHERE [FunctionName] = N'STOCKTAKE EXPORT'
      AND [ParameterName] = N'MODE'
      AND [Value] = N'WAREHOUSE'
)
BEGIN
    ;
END


IF NOT EXISTS (
    SELECT 1
    FROM [dbo].[FunctionParameterLookup]
    WHERE [FunctionName] = N'STOCKTAKE EXPORT'
      AND [ParameterName] = N'MODE'
      AND [Value] = N'SESSION'
)
BEGIN
    ;
END


IF NOT EXISTS (
    SELECT 1
    FROM [dbo].[FunctionParameterLookup]
    WHERE [FunctionName] = N'STOCKTAKE EXPORT'
      AND [ParameterName] = N'MODE'
      AND [Value] = N'SESSION_WH'
)
BEGIN
    ;
END


