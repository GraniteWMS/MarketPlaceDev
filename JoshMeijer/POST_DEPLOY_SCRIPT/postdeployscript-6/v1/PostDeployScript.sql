IF NOT EXISTS(SELECT ID FROM [Location] WHERE Barcode = 'SCRAP' OR [Name] = 'SCRAP')
 BEGIN
 INSERT INTO [Location] (Barcode, [Name], isActive) VALUES ('SCRAP', 'SCRAP', 1)
 END