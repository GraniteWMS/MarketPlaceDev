CREATE VIEW [dbo].[WebTemplate_UnpickTransactionToBarcode_Location]
AS
	SELECT Barcode AS [Location], [Name] AS [Description] FROM [Location]
