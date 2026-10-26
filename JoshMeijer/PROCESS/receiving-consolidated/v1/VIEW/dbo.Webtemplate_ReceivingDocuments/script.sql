CREATE VIEW [dbo].[Webtemplate_ReceivingDocuments]
AS
SELECT D.Number, D.TradingPartnerDescription AS Supplier
FROM Document D
WHERE D.Status IN ('RELEASED')
