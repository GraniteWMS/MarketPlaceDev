CREATE VIEW [dbo].[WebTemplate_Replenish_Location]
AS
SELECT Barcode, [Name] FROM [Location] WHERE [Type] = 'PICKFACE'
