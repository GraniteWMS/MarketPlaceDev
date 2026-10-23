CREATE VIEW [dbo].[webtemplate_POtoComplete]
AS
SELECT        dbo.[Document].Number, dbo.[Document].TradingPartnerCode as TradingPartner, dbo.[Document].Status, CONVERT(varchar(10), dbo.[Document].ExpectedDate, 1) AS ExpectedDate, SUM(dbo.DocumentDetail.Qty) AS Qty, 
                         SUM(dbo.DocumentDetail.ActionQty) AS ReceivedQty, CONVERT(varchar(10), dbo.[Document].AuditDate, 1) as LastUpdate
FROM            dbo.[Document] INNER JOIN
                         dbo.DocumentDetail ON dbo.[Document].ID = dbo.DocumentDetail.Document_id
WHERE        (dbo.[Document].Type = 'RECEIVING') AND (dbo.[Document].Status IN ('RELEASED','COMPLETE')) and [Document].AuditDate > getdate() - 3
GROUP BY dbo.[Document].Number, dbo.[Document].TradingPartnerCode, dbo.[Document].Status, CONVERT(varchar(10), dbo.[Document].ExpectedDate, 1),CONVERT(varchar(10), dbo.[Document].AuditDate, 1)
