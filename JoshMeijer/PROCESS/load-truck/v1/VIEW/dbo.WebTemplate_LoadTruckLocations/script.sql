CREATE VIEW [dbo].[WebTemplate_LoadTruckLocations]
AS
SELECT        Barcode, [Name], [Type] FROM [Location]
WHERE [Type] = 'TRUCK'
