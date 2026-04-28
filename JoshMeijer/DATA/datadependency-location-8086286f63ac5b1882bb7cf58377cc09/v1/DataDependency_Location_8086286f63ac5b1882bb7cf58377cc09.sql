INSERT INTO [Location] (Barcode, Name, Site, ERPLocation, isActive, NonStock, AuditDate, AuditUser, Version)
    SELECT '1-DELIVERYAPRON', '1-DELIVERYAPRON', '', '1', 1, 1,
    CASE WHEN getdate() IS NULL THEN CURRENT_TIMESTAMP ELSE getdate() END, 
    '0', 1