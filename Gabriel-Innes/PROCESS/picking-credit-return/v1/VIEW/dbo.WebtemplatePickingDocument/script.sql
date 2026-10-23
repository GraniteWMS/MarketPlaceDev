CREATE VIEW [dbo].[WebtemplatePickingDocument]
AS
	SELECT DISTINCT TOP 100 PERCENT Number,
			Document.ERPIdentification AS ErpInfo,
	        FORMAT(CreateDate, 'dd/MM/yyyy hh:mm') as Date
	FROM	Document 
			INNER JOIN DocumentDetail ON Document.ID = Document_id
	WHERE  Document.[Type] = 'ORDER'  AND 
	       Document.[Status] IN ('ENTERED', 'RELEASED') 
		   AND (ISNULL(Document.ERPIdentification, '') NOT LIKE 'AU%')
    ORDER BY Date ASC
