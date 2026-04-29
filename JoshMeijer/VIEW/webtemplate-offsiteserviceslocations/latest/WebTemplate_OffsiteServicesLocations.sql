CREATE VIEW [dbo].[WebTemplate_OffsiteServicesLocations]
AS
SELECT        Barcode, [Name], [Type],[Site] FROM [Location]
WHERE [TYPE] in ('OFFSITESERVICES')
