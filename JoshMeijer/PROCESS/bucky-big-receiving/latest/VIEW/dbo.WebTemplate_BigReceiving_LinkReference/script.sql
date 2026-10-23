CREATE VIEW [dbo].[WebTemplate_BigReceiving_LinkReference]
AS
SELECT DISTINCT RouteName AS LinkReference FROM Document WHERE [Type] = 'RECEIVING' AND [Status] NOT IN ('CANCELLED') AND ISNULL(RouteName, '') <> ''
