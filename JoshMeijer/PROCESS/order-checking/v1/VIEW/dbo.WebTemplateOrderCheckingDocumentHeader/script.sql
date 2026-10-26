CREATE VIEW [dbo].[WebTemplateOrderCheckingDocumentHeader] as
SELECT Number, FLOOR(SUM(ISNULL(ActionQty, 0)) / SUM(Qty) * 100) as Progress, Document.Description, 
TradingPartnerCode, TradingPartnerDescription, Document.ERPLocation
FROM Document INNER JOIN
DocumentDetail ON Document.ID = DocumentDetail.Document_id
GROUP BY Number, Document.Description, 
TradingPartnerCode, TradingPartnerDescription, Document.ERPLocation