CREATE VIEW WebtemplateDocumentsToPick
AS
SELECT DISTINCT Document.Number, DocumentDetail.Comment Cage, Document.CreateDate
FROM	Document 
		INNER JOIN DocumentDetail ON Document.ID = DocumentDetail.Document_id
WHERE	Completed = 0 
		AND Cancelled = 0
		AND Qty > ActionQty
		AND Document.[Type] = 'ORDER'
		AND (Document.ERPIdentification LIKE 'AU-%' OR Document.Number LIKE 'M-%')
		AND Number NOT LIKE '%-'
		AND Document.Status IN ('ENTERED', 'RELEASED')
		AND ISNULL(Comment, '') != '' 