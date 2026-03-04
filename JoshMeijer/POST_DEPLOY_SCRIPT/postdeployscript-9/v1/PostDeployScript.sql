IF NOT EXISTS (SELECT 1 FROM Location WHERE Barcode = 'SCRAP')
BEGIN
    INSERT INTO Location (Barcode, Name, isActive, NonStock)
    VALUES ('SCRAP', 'SCRAP', 1, 1)
END
