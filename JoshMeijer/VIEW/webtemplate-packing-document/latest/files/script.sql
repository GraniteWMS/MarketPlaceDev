CREATE VIEW [dbo].[WebTemplate_Packing_Document]
AS
SELECT Number AS DocumentNumber, CreateDate, RouteName, CONCAT(TradingPartnerCode, ' - ', TradingPartnerDescription) AS Customer
FROM [Document] 
WHERE [Type] = 'ORDER' AND [Status] NOT IN('CANCELLED')
AND EXISTS(SELECT ID FROM DocumentDetail WHERE ActionQty <> PackedQty AND Document_id = Document.ID)
AND CreateDate > DATEADD(DAY, -100, GETDATE())
