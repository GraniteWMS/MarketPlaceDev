CREATE VIEW [dbo].[Label_MasterItem]
AS
WITH ofv AS (
    SELECT
        ofvm.BelongsTo_id,
        ofc.Name AS FieldName,
        ofvm.Value  
    FROM dbo.OptionalFieldValues_MasterItem AS ofvm
    INNER JOIN dbo.OptionalFields AS ofc
        ON ofc.ID = ofvm.OptionalField_id
    WHERE ofc.Name IN ('LabelDescription1','LabelDescription2','UPC','LabelStockCode','CASE_GTIN','StorageInstruction')
),
ofv_pivot AS (
    SELECT
        BelongsTo_id,
        MAX(CASE WHEN FieldName = 'LabelDescription1' THEN Value END) AS LabelDescription1,
        MAX(CASE WHEN FieldName = 'LabelDescription2' THEN Value END) AS LabelDescription2,
        MAX(CASE WHEN FieldName = 'UPC'              THEN Value END) AS UPC,
        MAX(CASE WHEN FieldName = 'LabelStockCode'   THEN Value END) AS LabelStockCode,
        MAX(CASE WHEN FieldName = 'CASE_GTIN'        THEN Value END) AS CASE_GTIN,
        MAX(CASE WHEN FieldName = 'StorageInstruction'        THEN Value END) AS StorageInstruction
    FROM ofv
    GROUP BY BelongsTo_id
)
SELECT
    MI.Code,
    MI.FormattedCode,
    MI.Description,
    MI.UOM,
    MI.Category,
    MI.Type,
    cus_var.Juliandate,
    cus_var.Plant,
    CONCAT(cus_var.Juliandate,' ', cus_var.Plant) AS JulianPlant,
    
    ofp.LabelStockCode,
    cus_var.BBDate,
    ofp.LabelDescription1,
    ofp.LabelDescription2,
    PackageType AS CasePackDesc,
    ofp.CASE_GTIN,
    isnull(ofp.StorageInstruction,'') as StorageInstruction,
    cus_var.GS1Human,
    cus_var.GS1Barcode
    
    
FROM dbo.MasterItem AS MI
LEFT JOIN ofv_pivot AS ofp
    ON ofp.BelongsTo_id = MI.ID
LEFT JOIN dbo.custom_CurrentCaseLabelVariables AS cus_var
    ON MI.Code = cus_var.MasterItemCode;
