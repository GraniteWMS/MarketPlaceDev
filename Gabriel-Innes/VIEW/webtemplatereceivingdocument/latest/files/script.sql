CREATE VIEW [dbo].[WebtemplateReceivingDocument]
AS
	SELECT TOP 100 PERCENT Number,
			Document.ERPIdentification AS ErpInfo,
	        FORMAT(CreateDate, 'dd/MM/yyyy hh:mm') as Date
	FROM Document 
	WHERE  [Type] = 'RECEIVING'  AND 
	       [Status] IN ('ENTERED', 'RELEASED')
    ORDER BY CreateDate DESC
