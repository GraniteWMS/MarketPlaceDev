CREATE VIEW [dbo].[WebTemplate_Picking_Document]
AS
SELECT Number AS DocumentNumber, CreateDate, RouteName, CONCAT(TradingPartnerCode, ' - ', TradingPartnerDescription) AS Customer
FROM [Document] WHERE [Type] = 'ORDER' AND [Status] NOT IN('CANCELLED', 'COMPLETE')
