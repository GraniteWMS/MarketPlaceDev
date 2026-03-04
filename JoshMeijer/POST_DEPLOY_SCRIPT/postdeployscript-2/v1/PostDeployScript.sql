IF NOT EXISTS(SELECT ID FROM [Location] WHERE Barcode = 'DIS' OR [Name] = 'DIS')
 BEGIN
  INSERT INTO [Location] (Barcode, [Name], isActive) VALUES ('DIS', 'DIS', 1)
 END