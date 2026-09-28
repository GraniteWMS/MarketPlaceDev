CREATE VIEW WebTemplate_CageReceiving_Document as
SELECT Number as Document, TradingPartnerDescription as Supplier, Document.RouteName as Cage
FROM Document CROSS APPLY
(
    SELECT COUNT(ID) as ActionableLines
    FROM DocumentDetail
    WHERE Document_id = Document.ID AND ISNULL(ActionQty, 0) < Qty AND Completed = 0
) detail
WHERE [Type] = 'RECEIVING' AND [Status] = 'RELEASED' AND detail.ActionableLines > 0
