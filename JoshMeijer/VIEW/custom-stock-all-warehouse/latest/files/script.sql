CREATE VIEW [dbo].[Custom_Stock_All_Warehouse]
AS
SELECT
      LTRIM(RTRIM(MI.Code))        AS SORTCODE
    , SUM(TE.Qty)                  AS QTYCOUNTED
    , 'KG'                         AS UOM
    , L.ERPLocation                AS [LOCATION]
FROM dbo.MasterItem MI
INNER JOIN dbo.TrackingEntity TE
    ON MI.ID = TE.MasterItem_id
INNER JOIN dbo.Location L
    ON TE.Location_id = L.ID
WHERE
    TE.InStock = 1
GROUP BY
      MI.Code
    , L.ERPLocation
HAVING SUM(TE.Qty) > 0;
