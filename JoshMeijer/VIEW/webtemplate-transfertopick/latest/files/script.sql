CREATE VIEW [dbo].[webtemplate_TransfertoPick]
AS
SELECT        dbo.[Document].Number,  dbo.Document.AssignedTo, dbo.[Document].Status, CONVERT(varchar(10), dbo.[Document].CreateDate, 1) AS CreateDate, SUM(dbo.DocumentDetail.Qty) AS Qty, 
                         SUM(dbo.DocumentDetail.ActionQty) AS PickedQty
FROM            dbo.[Document] INNER JOIN
                         dbo.DocumentDetail ON dbo.[Document].ID = dbo.DocumentDetail.Document_id
WHERE        (dbo.[Document].Type = 'TRANSFER') AND (dbo.[Document].Status IN ('ENTERED','RELEASED'))
AND Document.Number NOT LIKE 'TR[0-9][0-9][0-9][0-9][0-9][0-9]'
GROUP BY dbo.[Document].Number,  dbo.Document.AssignedTo,dbo.[Document].Status, CONVERT(varchar(10), dbo.[Document].CreateDate, 1)
HAVING SUM(dbo.DocumentDetail.Qty) - SUM(dbo.DocumentDetail.ActionQty) >0
