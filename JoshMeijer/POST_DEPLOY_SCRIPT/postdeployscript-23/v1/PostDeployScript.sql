IF NOT EXISTS (SELECT * FROM Location WHERE Barcode = 'DIS')
BEGIN
	INSERT INTO Location (Barcode, Name, isActive)
	VALUES ('DIS', 'DIS', 1)
END