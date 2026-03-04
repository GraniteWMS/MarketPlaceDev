CREATE VIEW [dbo].[webtemplate_POtoPost]
AS
SELECT     DISTINCT   dbo.[Document].Number, dbo.[Document].TradingPartnerDescription, dbo.[Document].Status, CONVERT(varchar(10), dbo.[Document].ExpectedDate, 1) AS ExpectedDate, SUM(dbo.DocumentDetail.Qty) AS Qty, 
                         SUM(dbo.DocumentDetail.ActionQty) AS ReceivedQty, TX.IntegrationStatus
FROM            dbo.[Document] INNER JOIN
                         dbo.DocumentDetail ON dbo.[Document].ID = dbo.DocumentDetail.Document_id INNER JOIN
						 dbo.[Transaction] TX ON TX.DocumentLine_id = DocumentDetail.ID AND TX.IntegrationStatus = 0 AND TX.[TYPE] = 'RECEIVE' AND isnull(TX.ReversalTransaction_id,0) = 0
WHERE        (dbo.[Document].Type = 'RECEIVING') AND (dbo.[Document].Status IN ('RELEASED','COMPLETE')) 
GROUP BY dbo.[Document].Number, dbo.[Document].TradingPartnerDescription, dbo.[Document].Status, CONVERT(varchar(10), dbo.[Document].ExpectedDate, 1), TX.IntegrationStatus
