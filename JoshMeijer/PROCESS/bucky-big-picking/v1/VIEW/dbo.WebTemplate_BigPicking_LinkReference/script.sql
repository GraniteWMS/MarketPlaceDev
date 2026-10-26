CREATE VIEW [dbo].[WebTemplate_BigPicking_LinkReference]
AS
SELECT DISTINCT RouteName AS LinkReference FROM Document WHERE [Type] = 'ORDER' AND [Status] NOT IN ('CANCELLED') AND ISNULL(RouteName, '') <> ''
