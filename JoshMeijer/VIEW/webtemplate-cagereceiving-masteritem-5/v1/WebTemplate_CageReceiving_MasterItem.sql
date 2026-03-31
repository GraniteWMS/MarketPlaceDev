CREATE VIEW WebTemplate_CageReceiving_MasterItem as
SELECT Document.Number as Document, Code, MasterItem.[Description], CONCAT(ISNULL(ActionQty, 0), ' of ', Qty) as Completion
FROM Document INNER JOIN
DocumentDetail ON Document.ID = DocumentDetail.Document_id INNER JOIN
MasterItem ON DocumentDetail.Item_id = MasterItem.ID
WHERE Qty > ISNULL(ActionQty, 0) AND Completed = 0
