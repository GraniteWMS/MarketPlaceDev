CREATE VIEW [dbo].[WebtemplateShortPickDocument]
AS
	SELECT TOP 100 PERCENT Number,
	        FORMAT(CreateDate, 'dd/MM/yyyy') as Date
	FROM Document 
	WHERE  [Type] = 'ORDER'  AND 
	       [Status] IN ('ENTERED', 'RELEASED')
    ORDER BY CreateDate ASC
