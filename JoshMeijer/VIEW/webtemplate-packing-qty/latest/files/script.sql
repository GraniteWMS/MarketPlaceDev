CREATE VIEW WebTemplate_Packing_Qty
AS
	SELECT 
	D.Number AS DocumentNumber,
	MI.Code AS ItemCode,
	CONVERT(VARCHAR, CONVERT(DATE, T.Comment), 101) AS ExpiryDate,
	ISNULL(SUM(IIF(T.[Type] = 'PICK', T.ActionQty, 0)), 0) AS Picked,
	ISNULL(SUM(IIF(T.[Type] = 'PACK', T.ActionQty, 0)), 0) AS Packed
	FROM [Transaction] T
	INNER JOIN Document D ON T.Document_id = D.ID
	INNER JOIN MasterItem MI ON T.FromMasterItem_id = MI.ID
	WHERE T.[Type] IN ('PICK', 'PACK')
	AND ISNULL(T.ReversalTransaction_id, 0) = 0
	GROUP BY D.Number, MI.Code, CONVERT(VARCHAR, CONVERT(DATE, T.Comment), 101)
