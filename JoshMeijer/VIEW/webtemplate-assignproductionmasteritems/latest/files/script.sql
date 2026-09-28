CREATE VIEW [dbo].[Webtemplate_AssignProductionMasterItems]
AS
SELECT Code, Description, [Category], [Type] 
FROM [MasterItem]
WHERE [isActive] = 1  AND [Type] = 'FINISHED PRODUCT'
