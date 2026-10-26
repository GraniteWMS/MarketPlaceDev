CREATE VIEW [dbo].[WebTemplate_MasterItems]
AS
SELECT        Code, [Description], [Category], [Type] FROM [MasterItem]
WHERE isActive = 1
