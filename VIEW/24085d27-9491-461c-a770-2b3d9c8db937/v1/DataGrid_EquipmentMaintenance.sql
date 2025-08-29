-- Step 3: Create a view that joins the custom table with Location for better display
CREATE VIEW [dbo].[DataGrid_EquipmentMaintenance] AS
SELECT 
    em.ID,
    em.EquipmentName,
    em.EquipmentType,
    em.SerialNumber,
    l.Name AS LocationName,
    l.Barcode AS LocationCode,
    em.MaintenanceType,
    em.MaintenanceDate,
    em.NextMaintenanceDate,
    em.TechniciansAssigned,
    em.EstimatedHours,
    em.ActualHours,
    em.MaintenanceCost,
    em.MaintenanceNotes,
    em.IsCompleted,
    em.CompletedDate,
    em.Priority,
    em.Status,
    em.CreatedBy,
    em.CreatedDate,
    em.AuditDate,
    em.AuditUser,
    -- Calculated fields
    CASE 
        WHEN em.IsCompleted = 1 THEN 'Completed'
        WHEN em.NextMaintenanceDate < GETDATE() AND em.IsCompleted = 0 THEN 'Overdue'
        WHEN em.MaintenanceDate <= GETDATE() AND em.IsCompleted = 0 THEN 'Due Now'
        ELSE 'Scheduled'
    END AS MaintenanceStatus,
    
    CASE 
        WHEN em.ActualHours IS NOT NULL AND em.EstimatedHours > 0 
        THEN CAST(((em.ActualHours - em.EstimatedHours) / em.EstimatedHours * 100) AS DECIMAL(5,1))
        ELSE NULL
    END AS HoursVariancePercent,
    
    DATEDIFF(DAY, GETDATE(), em.NextMaintenanceDate) AS DaysUntilNext,
    
    CASE 
        WHEN em.Priority = 'Critical' THEN 1
        WHEN em.Priority = 'High' THEN 2  
        WHEN em.Priority = 'Medium' THEN 3
        WHEN em.Priority = 'Low' THEN 4
        ELSE 5
    END AS PrioritySortOrder

FROM [dbo].[Custom_EquipmentMaintenance] em
INNER JOIN Location l ON em.Location_id = l.ID
WHERE l.isActive = 1