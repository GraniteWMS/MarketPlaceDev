CREATE VIEW [dbo].[webtemplate_OrdersToPack]
AS
SELECT        dbo.[Document].Number, dbo.[Document].TradingPartnerDescription, dbo.[Document].Status, CONVERT(varchar(10), dbo.[Document].ExpectedDate, 1) AS ExpectedDate, SUM(dbo.DocumentDetail.Qty) AS OrderQty, 
                         SUM(dbo.DocumentDetail.PackedQty) AS Packed, SUM(dbo.DocumentDetail.Qty) - SUM(dbo.DocumentDetail.PackedQty) AS [To Pack]
FROM            dbo.[Document] INNER JOIN
                         dbo.DocumentDetail ON dbo.[Document].ID = dbo.DocumentDetail.Document_id
WHERE        (dbo.[Document].Type = 'ORDER') AND (dbo.[Document].Status IN ('RELEASED','PACKING','BACKORDER'))
GROUP BY dbo.[Document].Number, dbo.[Document].TradingPartnerDescription, dbo.[Document].Status, CONVERT(varchar(10), dbo.[Document].ExpectedDate, 1)
