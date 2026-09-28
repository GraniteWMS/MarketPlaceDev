CREATE VIEW [dbo].[Webtemplate_AssignProductionPreformMasterItems]
AS
SELECT Code, Description, [Category], [Type] 
FROM [MasterItem]
WHERE [isActive] = 1  AND [Type] = 'PREFORM'
