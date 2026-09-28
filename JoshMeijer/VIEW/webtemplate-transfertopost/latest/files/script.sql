CREATE VIEW [dbo].[webtemplate_TransfertoPost]
AS
SELECT        dbo.[Document].Number, dbo.[Document].Status, 
SUM(dbo.DocumentDetail.Qty) AS Qty, 
SUM(dbo.DocumentDetail.ActionQty) AS PickedQty
FROM            dbo.[Document] INNER JOIN
                         dbo.DocumentDetail ON dbo.[Document].ID = dbo.DocumentDetail.Document_id
WHERE        (dbo.[Document].Type = 'TRANSFER') AND (dbo.[Document].Status IN ('RELEASED','COMPLETE'))
AND (SELECT TOP 1 1 FROM Integration_Transactions IT WHERE IT.Document = Document.Number) = 1
GROUP BY dbo.[Document].Number, dbo.[Document].Status
