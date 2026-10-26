CREATE VIEW [dbo].[WebTemplate_ConfirmTransfer_MasterItem]
AS
SELECT 
D.Number AS DocumentNumber,
TE.Barcode AS Barcode,
MI.Code AS ItemCode,
MI.[Description] AS ItemDescription,
SUM(T.ActionQty) AS Qty
FROM [Transaction] T
INNER JOIN MasterItem MI ON T.FromMasterItem_id = MI.ID
INNER JOIN Document D ON T.Document_id = D.ID
INNER JOIN TrackingEntity TE ON T.TrackingEntity_id = TE.ID
LEFT JOIN [Transaction] ConfirmedTransferTransactions 
ON ConfirmedTransferTransactions.Document_id = D.ID 
AND ConfirmedTransferTransactions.Comment = TE.Barcode
AND ConfirmedTransferTransactions.[Process] = 'CONFIRMTRANSFER'
AND ISNULL(ConfirmedTransferTransactions.ReversalTransaction_id, 0) = 0
WHERE T.[Type] = 'TRANSFER' AND T.Process = 'TRANSFER'
AND ISNULL(T.ReversalTransaction_id, 0) = 0
AND ConfirmedTransferTransactions.ID IS NULL
GROUP BY
D.Number,
TE.Barcode,
MI.Code,
MI.[Description]
