CREATE VIEW [dbo].[WebTemplate_UnconsumeTransaction_TransactionID]
AS
SELECT D.Number DocumentNumber,
T.ID TransactionID,
TE.Batch,
U.[Name] [User],
T.[Date],
MI.Code ItemCode,
CONVERT(BIGINT, T.ActionQty) ConsumedQty
FROM [Transaction] T WITH (NOLOCK)
INNER JOIN Document D ON T.Document_id = D.ID
INNER JOIN MasterItem MI ON T.FromMasterItem_id = MI.ID
INNER JOIN Users U ON T.[User_id] = U.ID
INNER JOIN TrackingEntity TE ON T.TrackingEntity_id = TE.ID
WHERE T.[Type] = 'CONSUME'
AND ISNULL(T.ReversalTransaction_id, 0) = 0
AND T.IntegrationStatus = 0
