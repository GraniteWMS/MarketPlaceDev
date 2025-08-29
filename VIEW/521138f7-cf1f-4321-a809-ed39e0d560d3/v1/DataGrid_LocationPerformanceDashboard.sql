-- Create the final DataGrid view that depends on the analysis view
CREATE VIEW DataGrid_LocationPerformanceDashboard AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY ActivityScore DESC, UtilizationPercentage DESC) as ID,
    LocationID,
    LocationName,
    LocationCode,
    TotalTrackingEntities,
    InStockEntities,
    UtilizationPercentage,
    UtilizationLevel,
    ActivityScore,
    EfficiencyRatio,
    
    -- Add ranking
    ROW_NUMBER() OVER (ORDER BY ActivityScore DESC, UtilizationPercentage DESC) as PerformanceRank,
    
    -- Calculate composite score
    (ActivityScore + (UtilizationPercentage * 0.5)) as CompositeScore,
    
    -- Risk assessment
    CASE 
        WHEN UtilizationLevel = 'No Activity' THEN 'High Risk'
        WHEN UtilizationLevel = 'Very Low Utilization' THEN 'Medium Risk'
        WHEN UtilizationLevel = 'Low Utilization' THEN 'Low Risk'
        ELSE 'Optimal'
    END as RiskLevel,
    
    -- Performance category
    CASE 
        WHEN ActivityScore >= 75 AND UtilizationPercentage >= 80 THEN 'Top Performer'
        WHEN ActivityScore >= 50 AND UtilizationPercentage >= 60 THEN 'Good Performer'
        WHEN ActivityScore >= 25 OR UtilizationPercentage >= 30 THEN 'Average Performer'
        ELSE 'Needs Attention'
    END as PerformanceCategory
    
FROM View_LocationPerformanceAnalysis