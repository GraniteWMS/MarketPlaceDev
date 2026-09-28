CREATE VIEW [dbo].[WebTemplate_PeanutManufacture_Document]
AS
	SELECT 
	Number AS DocumentNumber, 
	CONVERT(VARCHAR, CreateDate, 111) AS CreateDate
	FROM Document
	WHERE [Type] = 'WORKORDER'
	AND [ERPLocation] = 'Peanut Warehouse'
	AND [Status] NOT IN ('COMPLETE', 'CANCELLED', 'ONHOLD')
