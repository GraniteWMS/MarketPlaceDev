CREATE VIEW EmailTemplatePickedLines
AS
SELECT	Document.Number as DocumentNumber,
		MasterItem.Code,
		MasterItem.Description,
		DocumentDetail.Qty AS OrderedQty,
		DocumentDetail.ActionQty as PickedQty,
		DocumentDetail.Comment
FROM	Document 
		INNER JOIN DocumentDetail ON Document.ID = DocumentDetail.Document_id 
		INNER JOIN MasterItem ON DocumentDetail.Item_id = MasterItem.ID
WHERE	Document.Type = 'ORDER'
		AND DocumentDetail.Cancelled = 0
