IF NOT EXISTS (SELECT * FROM OptionalFields WHERE Name = 'ImageURL')
BEGIN
	INSERT INTO OptionalFields (Name, isActive, AppliesTo)
	VALUES ('ImageURL', 1 , 'MASTERITEM')
END