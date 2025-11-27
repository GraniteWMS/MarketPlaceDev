CREATE PROCEDURE [dbo].[WebTemplate_PurchaseOrderPostDetail]
@value NVARCHAR(100)  
AS
BEGIN
SELECT  TSQL.* FROM 
(SELECT     DISTINCT   dbo.[Document].Number, DocumentDetail.LineNumber, M.Code,M.Description, MAX(dbo.DocumentDetail.Qty) AS Qty, 
                         SUM(TX.ActionQty) AS ReceivedQty
FROM            dbo.[Document] INNER JOIN
                         dbo.DocumentDetail ON dbo.[Document].ID = dbo.DocumentDetail.Document_id INNER JOIN
						 dbo.MasterItem M ON dbo.[DocumentDetail].Item_id = M.ID INNER JOIN 
						 dbo.[Transaction] TX ON TX.DocumentLine_id = DocumentDetail.ID AND TX.IntegrationStatus = 0 AND TX.[TYPE] = 'RECEIVE' AND isnull(TX.ReversalTransaction_id,0) = 0
WHERE        (dbo.[Document].Type = 'RECEIVING') AND (dbo.[Document].Status IN ('RELEASED','COMPLETE')) AND (Document.Number = @value) 
GROUP BY dbo.[Document].Number, DocumentDetail.LineNumber, M.Code,M.Description) TSQL
ORDER BY CONVERT(decimal(18,0),TSQL.LineNumber)
 
END
