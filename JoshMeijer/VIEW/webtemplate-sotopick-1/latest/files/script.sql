CREATE VIEW [dbo].[webtemplate_SOtoPick]
AS
SELECT        dbo.[Document].Number, dbo.[Document].TradingPartnerDescription, dbo.[Document].Status, CONVERT(varchar(10), dbo.[Document].ExpectedDate, 1) AS ExpectedDate, SUM(dbo.DocumentDetail.Qty) AS Qty, 
                         SUM(dbo.DocumentDetail.ActionQty) AS PickedQty
FROM            dbo.[Document] INNER JOIN
                         dbo.DocumentDetail ON dbo.[Document].ID = dbo.DocumentDetail.Document_id
WHERE        (dbo.[Document].Type = 'ORDER') AND (dbo.[Document].Status IN ('RELEASED'))
GROUP BY dbo.[Document].Number, dbo.[Document].TradingPartnerDescription, dbo.[Document].Status, CONVERT(varchar(10), dbo.[Document].ExpectedDate, 1)
