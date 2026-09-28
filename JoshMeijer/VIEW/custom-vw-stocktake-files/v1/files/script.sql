
CREATE VIEW [dbo].[Custom_vw_Stocktake_Files]
AS
SELECT
      MI.Code                      AS ItemCode
    , SUM(STL.ApprovedQty)         AS TotalQty
    , STL.StockTakeSession_id
    , L.ERPLocation
    , MI.UOM
    , 1                            AS Conversion
    , STL.Status
    , STS.Name                     AS SessionName
    , MI.Category
FROM dbo.StockTakeSession STS
INNER JOIN dbo.StockTakeLines STL
    ON STS.ID = STL.StockTakeSession_id
LEFT JOIN dbo.TrackingEntity TE
    ON STL.Barcode = TE.Barcode
LEFT JOIN dbo.MasterItem MI
    ON TE.MasterItem_id = MI.ID
LEFT JOIN dbo.Location L
    ON TE.Location_id = L.ID
WHERE STL.Status = 'COMPLETED'
GROUP BY
      MI.Code
    , STL.StockTakeSession_id
    , L.ERPLocation
    , STL.Status
    , MI.UOM
    , STS.Name
    , MI.Category;
