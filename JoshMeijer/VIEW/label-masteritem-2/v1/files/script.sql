CREATE VIEW [dbo].[Label_MasterItem]
AS
WITH OldestStock AS
(
    SELECT
        TE.MasterItem_id,
        L.Barcode AS Bin,
        ROW_NUMBER() OVER
        (
            PARTITION BY TE.MasterItem_id
            ORDER BY TE.CreatedDate ASC, TE.ID ASC
        ) AS RN
    FROM dbo.TrackingEntity TE
    INNER JOIN dbo.Location L
        ON L.ID = TE.Location_id
    WHERE
        TE.InStock = 1
        AND TE.Qty > 0
        AND TE.Location_id IS NOT NULL
)
SELECT
    MI.Code,
    MI.FormattedCode,
    CONCAT(SUBSTRING(MI.Code,4,100),'  ',SUBSTRING(MI.Code,1,3),'  ') AS OldCode,
    MI.Description,
    MI.UOM,
    MI.Category,
    SUBSTRING(MI.LATEST,4,100) AS LATEST,
    MI.PACK,
    SUBSTRING(MI.Code,1,3) AS Brand,
    ISNULL(OS.Bin, '') AS Bin
FROM dbo.Integration_Accpac_MasterItem MI
LEFT JOIN dbo.MasterItem M
    ON M.Code = MI.Code
LEFT JOIN OldestStock OS
    ON OS.MasterItem_id = M.ID
   AND OS.RN = 1;
