CREATE VIEW [dbo].[WebTemplate_IngredientSuppliers]
AS
SELECT        Barcode as [Location] FROM [Location]
WHERE isActive = 1 AND [Type] = 'NON EGG SUPPLIER'
