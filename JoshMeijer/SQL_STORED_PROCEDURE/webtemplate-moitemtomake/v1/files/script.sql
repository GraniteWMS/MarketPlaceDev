
CREATE PROCEDURE [dbo].[webTemplate_MOItemToMake]
@value NVARCHAR(100)  
AS
BEGIN
SELECT TOP 1   M.Code,M.Description, dbo.DocumentDetail.Qty AS Qty, 
                         DocumentDetail.ActionQty AS QtyMade
FROM            dbo.[Document] INNER JOIN
                         dbo.DocumentDetail ON dbo.[Document].ID = dbo.DocumentDetail.Document_id INNER JOIN
						 dbo.MasterItem M ON dbo.[DocumentDetail].Item_id = M.ID 
WHERE        (dbo.[Document].Type = 'WORKORDER') AND (dbo.[Document].Status IN ('RELEASED','COMPLETE')) AND (dbo.[DocumentDetail].Type = 'OUTPUT')
AND (Document.Number = @value) 
END
