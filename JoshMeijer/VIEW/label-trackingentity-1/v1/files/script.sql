CREATE VIEW [dbo].[Label_TrackingEntity]
AS
SELECT 
    TE.Barcode,
    MI.Code,
    MI.FormattedCode,
    MI.Description,
    TE.Qty,
    TE.SerialNumber,
    TE.Batch,
    Format(TE.ExpiryDate,'MM/dd/yyyy') as ExpiryDate,
    MI.Category,
    MI.Type,
    MI.UOM,
    CASE WHEN ManufactureDate IS NULL THEN Format(TE.CreatedDate,'MM/dd/yyyy') ELSE Format(TE.ManufactureDate,'MM/dd/yyyy') END as CreatedDateOnly,
    Format(TE.CreatedDate,'HH:mm:ss') as CreatedTime,
    TE.CreatedDate as CreatedDate,
    CASE WHEN ManufactureDate IS NULL THEN Format(TE.CreatedDate,'MM/dd/yyyy') ELSE Format(TE.ManufactureDate,'MM/dd/yyyy') END as ManufactureDate,
    CASE WHEN ManufactureDate IS NULL THEN dbo.GetJulianDate(TE.CreatedDate) ELSE dbo.GetJulianDate(TE.ManufactureDate) END as JulienDate,
    
    MAX(CASE WHEN OptF.Name = 'Document' AND OptF.AppliesTo = 'TRACKINGENTITY' THEN OFV.Value END) AS Document,
    MAX(CASE WHEN OptF.Name = 'Weight' AND OptF.AppliesTo = 'TRACKINGENTITY' THEN OFV.Value END) AS Weight,
    MAX(CASE WHEN OptF.Name = 'ReceivingTemperature' AND OptF.AppliesTo = 'TRACKINGENTITY' THEN OFV.Value END) AS ReceivingTemperature,
    MAX(CASE WHEN OptF.Name = 'Seal' AND OptF.AppliesTo = 'TRACKINGENTITY' THEN OFV.Value END) AS Seal,
    MAX(CASE WHEN OptF.Name = 'Carrier' AND OptF.AppliesTo = 'TRACKINGENTITY' THEN OFV.Value END) AS Carrier,
    MAX(CASE WHEN OptF.Name = 'Supplier' AND OptF.AppliesTo = 'TRACKINGENTITY' THEN OFV.Value END) AS Supplier,
    (SELECT Location.Category FROM [Location] WHERE Barcode = (MAX(CASE WHEN OptF.Name = 'Supplier' AND OptF.AppliesTo = 'TRACKINGENTITY' THEN OFV.Value END))) AS Farm
FROM dbo.TrackingEntity TE
JOIN dbo.MasterItem MI ON MI.ID = TE.MasterItem_id
JOIN [Location] L On TE.Location_id = L.ID
LEFT JOIN dbo.OptionalFieldValues_TrackingEntity OFV 
    ON OFV.BelongsTo_id = TE.ID
LEFT JOIN dbo.OptionalFields OptF
    ON OptF.ID = OFV.OptionalField_id AND OptF.isActive = 1
GROUP BY 
    TE.Barcode, MI.Code, MI.FormattedCode, MI.Description, TE.Qty, TE.SerialNumber,
    TE.Batch, TE.ExpiryDate, MI.Category, MI.Type, MI.UOM, L.Barcode, L.Category,
    TE.CreatedDate,
    TE.ManufactureDate
