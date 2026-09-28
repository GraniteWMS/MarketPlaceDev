CREATE VIEW [dbo].[WebTemplate_PickStagingLocations]
AS
SELECT        Barcode, [Name], [Type] FROM [Location]
WHERE [Type] = 'STAGING' and isActive = 1
