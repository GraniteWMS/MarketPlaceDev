CREATE VIEW [dbo].[WebTemplate_UnreceiveTransaction_TransactionID]
AS
SELECT D.Number DocumentNumber,
T.ID TransactionID,
U.[Name] [User],
T.[Date],
MI.Code ItemCode,
CONVERT(BIGINT, T.ActionQty) ReceivedQty,
CE.Barcode Pallet
FROM [Transaction] T WITH (NOLOCK)
INNER JOIN Document D ON T.Document_id = D.ID
INNER JOIN MasterItem MI ON T.FromMasterItem_id = MI.ID
LEFT JOIN CarryingEntity CE ON T.ToContainableEntity_id = CE.ID
INNER JOIN Users U ON T.[User_id] = U.ID
WHERE T.[Type] = 'RECEIVE'
AND ISNULL(T.ReversalTransaction_id, 0) = 0
AND T.IntegrationStatus = 0
