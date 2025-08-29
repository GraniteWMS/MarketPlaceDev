-- Create the analysis layer view that depends on the base view
CREATE VIEW View_LocationPerformanceAnalysis AS
SELECT 
    LocationID,
    LocationName,
    LocationCode,
    TotalTrackingEntities,
    InStockEntities,
    
    -- Calculate utilization metrics
    CASE 
        WHEN TotalTrackingEntities = 0 THEN 0
        ELSE CAST(InStockEntities AS DECIMAL(10,2)) / TotalTrackingEntities * 100
    END as UtilizationPercentage,
    
    -- Classify utilization levels
    CASE 
        WHEN TotalTrackingEntities = 0 THEN 'No Activity'
        WHEN CAST(InStockEntities AS DECIMAL(10,2)) / TotalTrackingEntities >= 0.9 THEN 'High Utilization'
        WHEN CAST(InStockEntities AS DECIMAL(10,2)) / TotalTrackingEntities >= 0.7 THEN 'Medium Utilization'
        WHEN CAST(InStockEntities AS DECIMAL(10,2)) / TotalTrackingEntities >= 0.3 THEN 'Low Utilization'
        ELSE 'Very Low Utilization'
    END as UtilizationLevel,
    
    -- Performance scoring
    CASE 
        WHEN TotalTrackingEntities >= 1000 THEN 100
        WHEN TotalTrackingEntities >= 100 THEN 75
        WHEN TotalTrackingEntities >= 10 THEN 50
        WHEN TotalTrackingEntities > 0 THEN 25
        ELSE 0
    END as ActivityScore,
    
    -- Calculate efficiency ratio
    CASE 
        WHEN TotalTrackingEntities = 0 THEN 0
        ELSE InStockEntities
    END as EfficiencyRatio
    
FROM View_LocationPerformanceBase