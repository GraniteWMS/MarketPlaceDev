CREATE VIEW [dbo].[WebTemplate_CommonTasks]
AS
SELECT [Key] AS Task, [Value] AS [Description]
FROM SystemStaticData
WHERE [Group] = 'Tasks'
