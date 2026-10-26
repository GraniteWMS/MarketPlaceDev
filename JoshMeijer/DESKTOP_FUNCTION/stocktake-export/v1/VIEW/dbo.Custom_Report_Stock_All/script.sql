CREATE VIEW [dbo].[Custom_Report_Stock_All]
AS
SELECT
      LTRIM(RTRIM(MI.Code))        AS SORTCODE
    , CONVERT(INT, SUM(TE.Qty))    AS QTYCOUNTED
    , 'KG'                         AS UOM
FROM dbo.MasterItem MI
INNER JOIN dbo.TrackingEntity TE
    ON MI.ID = TE.MasterItem_id
INNER JOIN dbo.Location L
    ON TE.Location_id = L.ID
LEFT JOIN dbo.CarryingEntity CE
    ON TE.BelongsToEntity_id = CE.ID
WHERE
    TE.InStock = 1
    AND TE.Qty > 0
GROUP BY
    MI.Code;
