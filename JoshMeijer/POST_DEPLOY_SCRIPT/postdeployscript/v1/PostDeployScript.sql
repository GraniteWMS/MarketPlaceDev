IF NOT EXISTS(SELECT ID FROM [Location] WHERE Barcode = 'DIS' OR [Name] = 'DIS')
 BEGIN
  END