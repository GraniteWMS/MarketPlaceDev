CREATE VIEW [dbo].[WebTemplate_MasterItems_WIP]
AS
SELECT        Code, [Description], [Category], [Type] FROM [MasterItem]
WHERE isActive = 1 
