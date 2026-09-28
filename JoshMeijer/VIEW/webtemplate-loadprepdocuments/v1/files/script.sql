CREATE VIEW [dbo].[WebTemplate_LoadPrepDocuments]
AS
SELECT DISTINCT D.Number AS Document, D.TradingPartnerCode AS Customer
FROM [Transaction] TR
INNER JOIN Document D ON D.ID = TR.Document_id
					 AND D.[Type] = 'ORDER'
					 AND TR.[Type] = 'PICK'
					 
