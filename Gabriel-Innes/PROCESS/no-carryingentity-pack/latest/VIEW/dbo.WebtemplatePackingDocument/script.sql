CREATE VIEW [dbo].[WebtemplatePackingDocument]
AS
SELECT DISTINCT Document.Number AS Document 
FROM	Document 
		INNER JOIN DocumentDetail ON Document.ID = DocumentDetail.Document_id
WHERE	Completed = 0 
		AND Cancelled = 0
		AND ActionQty > PackedQty
		AND Document.Type = 'ORDER'
