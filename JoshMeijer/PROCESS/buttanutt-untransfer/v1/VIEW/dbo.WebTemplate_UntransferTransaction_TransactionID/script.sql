CREATE VIEW [dbo].[WebTemplate_UntransferTransaction_TransactionID]
AS
SELECT D.Number DocumentNumber,
T.ID TransactionID,
TE.Barcode,
U.[Name] [User],
T.[Date],
MI.Code ItemCode,
L.ERPLocation AS Warehouse,
CONVERT(FLOAT, T.ActionQty) TransferredQty
FROM [Transaction] T WITH (NOLOCK)
INNER JOIN Document D ON T.Document_id = D.ID
INNER JOIN MasterItem MI ON T.FromMasterItem_id = MI.ID
INNER JOIN TrackingEntity TE ON T.TrackingEntity_id = TE.ID
LEFT JOIN CarryingEntity CE ON T.ToContainableEntity_id = CE.ID
INNER JOIN Users U ON T.[User_id] = U.ID
INNER JOIN [Location] L ON T.ToLocation_id = L.ID
WHERE T.[Type] = 'TRANSFER'
AND ISNULL(T.ReversalTransaction_id, 0) = 0
AND T.IntegrationStatus = 0
