CREATE VIEW [dbo].[WebTemplate_MasterItems_Ingredients]
AS
SELECT        Code, [Description], [Category], [Type] FROM [MasterItem]
WHERE isActive = 1 and [Type] IN ('INGREDIENTS','CHEMICALS')
