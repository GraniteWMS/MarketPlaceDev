CREATE VIEW [dbo].[WebTemplate_Locations_Receiving]
AS
SELECT        Barcode FROM [Location]
WHERE isActive = 1 AND NonStock =0 and [Type] = 'RECEIVING'
