CREATE VIEW [dbo].[webtemplate_TransfertoStage]
AS
SELECT        dbo.[Document].Number, dbo.[Document].TradingPartnerCode, dbo.[Document].Status, CONVERT(varchar(10), dbo.[Document].ExpectedDate, 1) AS ExpectedDate, SUM(dbo.DocumentDetail.Qty) AS Qty, 
                         SUM(dbo.DocumentDetail.ActionQty) AS StageQty
FROM            dbo.[Document] INNER JOIN
                         dbo.DocumentDetail ON dbo.[Document].ID = dbo.DocumentDetail.Document_id
WHERE        (dbo.[Document].Type = 'TRANSFER') AND (dbo.[Document].Status IN ('RELEASED'))
GROUP BY dbo.[Document].Number, dbo.[Document].TradingPartnerCode, dbo.[Document].Status, CONVERT(varchar(10), dbo.[Document].ExpectedDate, 1)
