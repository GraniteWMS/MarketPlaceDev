CREATE VIEW [dbo].[webtemplate_ReceivingLocations]
AS
SELECT        L.Barcode , L.Name
FROM         
dbo.[Location] L
WHERE L.Type = 'CART' OR L.Type = 'RECEIVING'
