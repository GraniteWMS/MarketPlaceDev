CREATE VIEW WebTemplate_PickingEthical_Comment
AS
SELECT DISTINCT
T.Comment AS PickingCrate,
U.[Name] AS [User]
FROM [Transaction] T
INNER JOIN [Users] U ON T.[User_id] = U.ID
WHERE [Process] LIKE 'PICKING_ETHICAL%'
AND ISNULL(T.ReversalTransaction_id, 0) = 0
