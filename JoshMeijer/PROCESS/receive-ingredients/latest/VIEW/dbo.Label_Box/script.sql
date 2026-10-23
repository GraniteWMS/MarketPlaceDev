CREATE VIEW [dbo].[Label_Box]
AS
WITH OptionalFields AS (
    SELECT 
        OFV.BelongsTo_id AS TrackingEntityID,
        MAX(CASE WHEN OptF.Name = 'Document' THEN OFV.Value END) AS Document,
        MAX(CASE WHEN OptF.Name = 'Weight' THEN OFV.Value END) AS Weight,
        MAX(CASE WHEN OptF.Name = 'ReceivingTemperature' THEN OFV.Value END) AS ReceivingTemperature,
        MAX(CASE WHEN OptF.Name = 'Seal' THEN OFV.Value END) AS Seal,
        MAX(CASE WHEN OptF.Name = 'Carrier' THEN OFV.Value END) AS Carrier,
        MAX(CASE WHEN OptF.Name = 'Supplier' THEN OFV.Value END) AS Supplier
    FROM dbo.OptionalFieldValues_TrackingEntity OFV
    INNER JOIN dbo.OptionalFields OptF 
        ON OptF.ID = OFV.OptionalField_id 
        AND OptF.isActive = 1 
        AND OptF.AppliesTo = 'TRACKINGENTITY'
    GROUP BY OFV.BelongsTo_id
)
SELECT
    OptionalFieldsData.Document AS Barcode,
    '' AS DocumentReference,
    TE.Batch,
    MI.Code,
    MI.[Description],
    COUNT(TE.ID) AS PalletCount,
    SUM(ISNULL(TE.Qty, 0)) AS TotalQty,
    CONVERT(VARCHAR, FORMAT(MAX(ISNULL(TE.ManufactureDate, TE.CreatedDate)), 'yyyyMMdd'), 22) AS [Date],
    MAX(OptionalFieldsData.Document) AS Document,
    MAX(OptionalFieldsData.Weight) AS Weight,
    MAX(OptionalFieldsData.ReceivingTemperature) AS ReceivingTemperature,
    MAX(OptionalFieldsData.Seal) AS Seal,
    MAX(OptionalFieldsData.Carrier) AS Carrier,
    MAX(OptionalFieldsData.Supplier) AS Supplier,
    (
        SELECT TOP 1 L2.Category 
        FROM [Location] L2 
        WHERE L2.Barcode = MAX(OptionalFieldsData.Supplier)
    ) AS Farm
FROM dbo.TrackingEntity TE
INNER JOIN dbo.MasterItem MI ON TE.MasterItem_ID = MI.ID
INNER JOIN dbo.Location L ON TE.Location_id = L.ID
LEFT JOIN OptionalFields AS OptionalFieldsData ON OptionalFieldsData.TrackingEntityID = TE.ID
GROUP BY OptionalFieldsData.Document,TE.Batch, MI.Code, MI.[Description]
