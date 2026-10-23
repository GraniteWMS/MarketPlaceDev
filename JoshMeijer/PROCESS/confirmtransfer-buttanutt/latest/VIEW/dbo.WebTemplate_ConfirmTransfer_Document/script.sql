CREATE VIEW [dbo].[WebTemplate_ConfirmTransfer_Document]
AS
	SELECT 
	D.Number AS DocumentNumber, 
	D.ERPLocation AS FromLocation,
	MAX(DD.ToLocation) AS ToLocation,
	CONVERT(VARCHAR, CreateDate, 111) AS CreateDate
	FROM Document D
	INNER JOIN DocumentDetail DD ON DD.Document_id = D.ID
	WHERE D.[Type] = 'TRANSFER'
	AND DD.ActionQty <> DD.PackedQty
	AND D.[Status] NOT IN ('CANCELLED', 'ONHOLD')
	GROUP BY
	D.Number,
	D.ERPLocation,
	CONVERT(VARCHAR, CreateDate, 111)
