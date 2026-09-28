CREATE VIEW WebTemplate_Manufacture_Document
AS
	SELECT 
	Number AS DocumentNumber, 
	CONVERT(VARCHAR, CreateDate, 111) AS CreateDate
	FROM Document
	WHERE [Type] = 'WORKORDER'
	AND [Status] NOT IN ('COMPLETE', 'CANCELLED', 'ONHOLD')
