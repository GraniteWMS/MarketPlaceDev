CREATE VIEW [dbo].[webtemplate_SOtoPack]
AS
SELECT     DISTINCT   dbo.[Document].Number, dbo.[Document].TradingPartnerDescription, dbo.[Document].Status, CONVERT(varchar(10), dbo.[Document].ExpectedDate, 1) AS ExpectedDate,
						 SUM(dbo.DocumentDetail.ActionQty) - SUM(dbo.DocumentDetail.PackedQty) AS QtyToPack ,
                         SUM(dbo.DocumentDetail.ActionQty) as PickedQty,SUM(dbo.DocumentDetail.PackedQty) AS PackedQty
FROM            dbo.[Document] INNER JOIN
                         dbo.DocumentDetail ON dbo.[Document].ID = dbo.DocumentDetail.Document_id INNER JOIN
						 dbo.[Transaction] TX ON TX.DocumentLine_id = DocumentDetail.ID AND TX.[TYPE] = 'PICK' AND isnull(TX.ReversalTransaction_id,0) = 0
WHERE        (dbo.[Document].Type = 'ORDER') AND (dbo.[Document].Status IN ('ENTERED','RELEASED','COMPLETE')) 
GROUP BY dbo.[Document].Number, dbo.[Document].TradingPartnerDescription, dbo.[Document].Status, CONVERT(varchar(10), dbo.[Document].ExpectedDate, 1), TX.IntegrationStatus
