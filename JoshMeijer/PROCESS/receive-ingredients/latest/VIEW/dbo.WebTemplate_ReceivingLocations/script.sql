CREATE VIEW [dbo].[WebTemplate_ReceivingLocations]
AS
SELECT        Barcode as [Location] FROM [Location]
WHERE isActive = 1 AND Type = 'RECEIVING'
