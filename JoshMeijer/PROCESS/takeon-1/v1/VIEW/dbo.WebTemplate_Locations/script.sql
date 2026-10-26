CREATE VIEW [dbo].[WebTemplate_Locations]
AS
SELECT        Barcode, [Name], [Type] FROM [Location]
WHERE isActive = 1 AND NonStock =0
