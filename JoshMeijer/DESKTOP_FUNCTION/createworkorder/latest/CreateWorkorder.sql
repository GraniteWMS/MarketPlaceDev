-- =============================================
-- Desktop Function Data Upsert
-- =============================================
SET NOCOUNT ON;

IF EXISTS (SELECT 1 FROM [Functions] WHERE [Name] = N'CreateWorkorder')
BEGIN
    UPDATE [Functions]
    SET [Description] = N'Create Workorder',
        [Module] = N'WORKORDERDOCUMENT',
        [Script] = N'Function_GenerateWorkOrderDocuments',
        [IsActive] = 1
    WHERE [Name] = N'CreateWorkorder';
END
ELSE
BEGIN
    INSERT INTO [Functions] ([Name], [Description], [Module], [Script], [IsActive], [GUID])
    VALUES (N'CreateWorkorder', N'Create Workorder', N'WORKORDERDOCUMENT', N'Function_GenerateWorkOrderDocuments', 1, '61d048f5-b00c-f111-acf0-bc071d9457bd');
END

DELETE FROM [FunctionParameterLookup] WHERE [FunctionName] = N'CreateWorkorder';
DELETE FROM [FunctionParameter] WHERE [FunctionName] = N'CreateWorkorder';

-- FunctionParameter
INSERT INTO [FunctionParameter] ([FunctionName], [Name], [Description], [isBool], [GUID])
VALUES (N'CreateWorkorder', N'OutputCode', N'Select Output Code', NULL, '62d048f5-b00c-f111-acf0-bc071d9457bd');
INSERT INTO [FunctionParameter] ([FunctionName], [Name], [Description], [isBool], [GUID])
VALUES (N'CreateWorkorder', N'LoopCount', N'Amount of Batches', NULL, '63d048f5-b00c-f111-acf0-bc071d9457bd');

