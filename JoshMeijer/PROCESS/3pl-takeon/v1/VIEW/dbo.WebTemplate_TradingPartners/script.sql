CREATE VIEW [dbo].[WebTemplate_TradingPartners]
AS
SELECT Code, [Description] 
FROM TradingPartner
WHERE DocumentType = 'RECEIVING' 
