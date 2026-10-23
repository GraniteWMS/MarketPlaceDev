CREATE VIEW [dbo].[webtemplate_PurchaseOrderPostLookup]
AS
SELECT     DISTINCT   dbo.[Document].Number, dbo.[Document].TradingPartnerDescription, dbo.[Document].Status, CONVERT(varchar(10), dbo.[Document].ExpectedDate, 1) AS ExpectedDate, MAX(dbo.DocumentDetail.Qty) AS Qty, 
                         MAX(dbo.DocumentDetail.ActionQty) AS ReceivedQty, TX.IntegrationStatus
FROM            dbo.[Document] INNER JOIN
                         dbo.DocumentDetail ON dbo.[Document].ID = dbo.DocumentDetail.Document_id INNER JOIN
						 dbo.[Transaction] TX ON TX.DocumentLine_id = DocumentDetail.ID AND TX.IntegrationStatus = 0 AND TX.[TYPE] = 'RECEIVE' AND isnull(TX.ReversalTransaction_id,0) = 0
WHERE        (dbo.[Document].Type = 'RECEIVING') AND (dbo.[Document].Status IN ('ENTERED','RELEASED','COMPLETE')) 
GROUP BY dbo.[Document].Number, dbo.[Document].TradingPartnerDescription, dbo.[Document].Status, CONVERT(varchar(10), dbo.[Document].ExpectedDate, 1), TX.IntegrationStatus
