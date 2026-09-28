CREATE VIEW [dbo].[WebTemplate_Receiving_Document]
AS
	SELECT 
	Number AS DocumentNumber, 
	CONCAT(TradingPartnerCode, ' - ', TradingPartnerDescription) AS Vendor,
	CONVERT(VARCHAR, ExpectedDate, 111) AS RequiredByDate
	FROM Document
	WHERE [Type] = 'RECEIVING'
	AND [Status] NOT IN ('COMPLETE', 'CANCELLED', 'ONHOLD')
