-- First, let's create a very simple base view
CREATE VIEW View_LocationPerformanceBase AS
SELECT 
    l.ID as LocationID,
    l.Name as LocationName,
    l.Barcode as LocationCode,
    COUNT(DISTINCT te.ID) as TotalTrackingEntities,
    COUNT(CASE WHEN te.InStock = 1 THEN 1 END) as InStockEntities
FROM Location l
LEFT JOIN TrackingEntity te ON l.ID = te.Location_id
WHERE l.isActive = 1
GROUP BY l.ID, l.Name, l.Barcode