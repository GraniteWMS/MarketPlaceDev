CREATE VIEW [dbo].[Datagrid_BranchTransfer_Report]
AS
WITH TransferItems AS (
    SELECT D1.Number AS TransferNumber,
			T1.FromMasterItem_id,
			SUM(T1.ActionQty) AS IssuedQty
    FROM document D1
    JOIN [Transaction] T1 ON D1.ID = T1.Document_id
    WHERE D1.Number LIKE 'TRF%'
      AND T1.Type = 'DYNAMICTRANSFER'
    GROUP BY D1.Number, T1.FromMasterItem_id
),
ReceiptItems AS (
    SELECT 'TRF' + SUBSTRING(D2.Number, 4, LEN(D2.Number)) AS TransferNumber,
			T2.FromMasterItem_id,
			SUM(T2.ActionQty) AS ReceivedQty
    FROM document D2
    JOIN [Transaction] T2 ON D2.ID = T2.Document_id
    WHERE D2.Number LIKE 'TRC%'
      AND T2.Type = 'TRANSFER'
    GROUP BY SUBSTRING(D2.Number, 4, LEN(D2.Number)), T2.FromMasterItem_id
)
SELECT TI.TransferNumber,
		MI.Code AS ItemCode,
		TI.IssuedQty,
		COALESCE(RI.ReceivedQty, 0) AS ReceivedQty,
		TI.IssuedQty - COALESCE(RI.ReceivedQty, 0) AS PendingQty,
		CASE 
			WHEN COALESCE(RI.ReceivedQty, 0) = 0 THEN 'Not Received'
			WHEN TI.IssuedQty = COALESCE(RI.ReceivedQty, 0) THEN 'Fully Received'
			ELSE 'Partially Received'
		END AS ReceiptStatus
FROM TransferItems TI
INNER JOIN MasterItem MI ON TI.FromMasterItem_id = MI.ID
LEFT JOIN ReceiptItems RI ON 
    TI.TransferNumber = RI.TransferNumber AND
    TI.FromMasterItem_id = RI.FromMasterItem_id