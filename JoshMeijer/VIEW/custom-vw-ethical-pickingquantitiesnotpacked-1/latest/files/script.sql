CREATE VIEW [dbo].[Custom_VW_Ethical_PickingQuantitiesNotPacked]
AS
WITH LastPackedPCrates AS
(
SELECT
PCrate,
DateLastPacked
FROM
(
SELECT
ROW_NUMBER() OVER (PARTITION BY T.DocumentReference ORDER BY T.ID DESC) AS SeqID,
T.DocumentReference AS PCrate,
T.[Date] AS DateLastPacked
FROM [Transaction] T
WHERE
ISNULL(T.ReversalTransaction_id, 0) = 0
AND T.[Process] = 'PACKING_ETHICAL'
) TransactionSequence
WHERE SeqID = 1
)
SELECT
CE.Barcode AS PCrate,
MI.Code AS MasterItemCode,
D.Number AS DocumentNumber,
SUM(T.ActionQty) AS PickedQty
FROM [Transaction] T
INNER JOIN CarryingEntity CE ON T.Comment = CE.Barcode
INNER JOIN MasterItem MI ON T.FromMasterItem_id = MI.ID
INNER JOIN Document D ON T.Document_id = D.ID
LEFT JOIN LastPackedPCrates ON CE.Barcode = LastPackedPCrates.PCrate
WHERE
ISNULL(T.ReversalTransaction_id, 0) = 0
AND T.[Process] IN ('PICKING_ETHICAL_LOOSE', 'PICKING_ETHICAL')
AND T.[Date] > ISNULL(LastPackedPCrates.DateLastPacked, '2000-01-01')
AND CE.Barcode LIKE 'PC%'
GROUP BY
CE.Barcode,
MI.Code,
D.Number 
