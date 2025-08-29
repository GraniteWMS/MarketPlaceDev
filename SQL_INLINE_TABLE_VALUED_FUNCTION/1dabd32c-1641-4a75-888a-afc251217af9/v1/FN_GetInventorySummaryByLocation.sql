-- Step 1: Create a corrected table-valued function that returns inventory summary by location
CREATE FUNCTION [dbo].[FN_GetInventorySummaryByLocation] (@LocationCode VARCHAR(50))
RETURNS TABLE AS
RETURN
(
    SELECT 
        l.Name AS LocationName,
        l.Barcode AS LocationBarcode,
        l.Type AS LocationType,
        mi.Code AS ItemCode,
        mi.Description AS ItemDescription,
        mi.UOM,
        ISNULL(SUM(te.Qty), 0) AS TotalQuantity,
        COUNT(te.ID) AS TrackingEntityCount,
        MAX(te.CreatedDate) AS LastActivityDate,
        AVG(te.Value) AS AverageValue
    FROM Location l
    LEFT JOIN TrackingEntity te ON l.ID = te.Location_id AND te.InStock = 1
    LEFT JOIN MasterItem mi ON te.MasterItem_id = mi.ID
    WHERE (l.Barcode = @LocationCode OR @LocationCode IS NULL)
        AND l.isActive = 1
    GROUP BY l.ID, l.Name, l.Barcode, l.Type, mi.ID, mi.Code, mi.Description, mi.UOM
)