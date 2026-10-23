CREATE VIEW [dbo].[WebTemplate_Picking_Location]
AS
SELECT Barcode, [Name] FROM [Location] WHERE [Type] = 'PICKFACE'
