CREATE VIEW [dbo].[WebTemplate_Manufacture_Document]
AS
	SELECT 
	Number AS DocumentNumber, 
	FG.ProductDescription,
	FG.Batch,
	CONVERT(VARCHAR, CreateDate, 111) AS CreateDate,
	ERPLocation AS Warehouse
	FROM Document
	OUTER APPLY
	(SELECT TOP 1 DD.Batch, MI.[Description] AS ProductDescription
	FROM DocumentDetail DD
	INNER JOIN MasterItem MI ON DD.Item_id = MI.ID
	WHERE DD.Document_id = Document.ID AND DD.[Type] = 'OUTPUT') FG
	WHERE [Type] = 'WORKORDER'
	AND [Status] NOT IN ('COMPLETE', 'CANCELLED', 'ONHOLD')
