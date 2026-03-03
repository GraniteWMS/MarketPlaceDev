CREATE VIEW [dbo].[API_QueryDocumentProgress]
	AS 
SELECT DISTINCT  
         dbo.[Document].ID, dbo.[Document].Priority, dbo.[Document].ExpectedDate, dbo.[Document].Number, dbo.[Document].TradingPartnerCode AS TradingPartnerCode,dbo.[Document].TradingPartnerDescription AS TradingPartnerDescription, dbo.[Document].Description,dbo.[Document].ActionDate AS ActionDate, 
		 TSQL.DateStart AS Started, TSQL.DateStop AS Stopped, DATEDIFF(MI, TSQL.DateStart, TSQL.DateStop) AS Duration, 
		 TSQL3.Qty AS DocumentQty, 
		 TSQL3.ActionQty AS ActionQty, ISNULL(TSQL3.ActionQty / CAST(CASE WHEN TSQL3.Qty = 0 THEN 1 ELSE TSQL3.Qty END AS DECIMAL(38, 3)) * 100, 0.1) AS Progress, 
		 TSQL.[User] AS [User], 
		 dbo.[Document].ERPLocation AS Location, dbo.[Document].Site, dbo.[Document].Status, dbo.[Document].Type
FROM  dbo.[Document]  OUTER APPLY
             (SELECT MIN(dbo.[Transaction].Date) AS DateStart, MAX(dbo.[Transaction].Date) AS DateStop, MAX(dbo.Users.Name) [USER]
			   FROM   dbo.[Transaction]  INNER JOIN
			   Users ON [Transaction].User_id = Users.ID
			   WHERE Document_id = dbo.[Document].ID) AS TSQL CROSS APPLY
			 (SELECT ISNULL(SUM(DocumentDetail.Qty / DocumentDetail.UOMConversion), 0) as Qty, ISNULL(SUM(DocumentDetail.ActionQty / DocumentDetail.UOMConversion), 0) as ActionQty
				FROM DocumentDetail
				WHERE Document_id = Document.ID) TSQL3
WHERE (dbo.[Document].Status <> 'COMPLETE' OR AuditDate > getdate() - 14)
