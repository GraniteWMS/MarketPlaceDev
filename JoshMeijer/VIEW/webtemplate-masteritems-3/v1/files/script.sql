CREATE VIEW [dbo].[WebTemplate_MasterItems]
AS
SELECT        Code, [Description], [Category] FROM [MasterItem]
WHERE isActive = 1
