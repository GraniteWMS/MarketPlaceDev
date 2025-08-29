-- Step 2: Create a view that uses the corrected function to show all inventory summaries
CREATE VIEW [dbo].[DataGrid_InventorySummaryByLocation] AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY LocationName, ItemCode) AS ID,
    LocationName,
    LocationBarcode,
    LocationType,
    ItemCode,
    ItemDescription,
    UOM,
    TotalQuantity,
    TrackingEntityCount,
    LastActivityDate,
    CAST(AverageValue AS DECIMAL(19,2)) AS AverageValue,
    CASE 
        WHEN TotalQuantity = 0 THEN 'Empty'
        WHEN TotalQuantity < 10 THEN 'Low Stock'
        ELSE 'Normal'
    END AS StockStatus
FROM [dbo].[FN_GetInventorySummaryByLocation](NULL) -- NULL shows all locations
WHERE ItemCode IS NOT NULL -- Only show locations with items