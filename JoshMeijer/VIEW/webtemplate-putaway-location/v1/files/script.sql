CREATE VIEW WebTemplate_Putaway_Location
AS
SELECT Barcode, [Name] FROM [Location] WHERE [Type] = 'BULK'
