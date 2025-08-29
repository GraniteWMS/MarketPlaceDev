INSERT INTO [DataGrid] ([Group],[Name],[SQLView],[GridDefinition],[RowStyleRules],[PageSize],[UserGroup_id],[isApplicationGrid],[isCustomGrid],[User_id],[AuditDate],[AuditUser],[Version]) 
VALUES('Operations','EquipmentMaintenance','DataGrid_EquipmentMaintenance','[
        {"field":"ID","width":60,"hide":true,"filter":"agNumberColumnFilter"},
        {"field":"EquipmentName","headerName":"Equipment","width":180,"filter":"agTextColumnFilter","cellRenderer":"selectRecord","pinned":"left"},
        {"field":"EquipmentType","headerName":"Type","width":120,"filter":"agSetColumnFilter","filterParams":{"values":["Conveyor","Forklift","Packaging","Refrigeration","Scale","Other"]}},
        {"field":"SerialNumber","headerName":"Serial #","width":120,"filter":"agTextColumnFilter"},
        {"field":"LocationName","headerName":"Location","width":150,"filter":"agTextColumnFilter"},
        {"field":"MaintenanceType","headerName":"Maint. Type","width":120,"filter":"agSetColumnFilter","filterParams":{"values":["Preventive","Corrective","Emergency"]}},
        {"field":"Priority","headerName":"Priority","width":100,"filter":"agSetColumnFilter","filterParams":{"values":["Low","Medium","High","Critical"]},"cellRenderer":"priorityCellRenderer","sort":"asc","sortIndex":0},
        {"field":"MaintenanceStatus","headerName":"Status","width":120,"filter":"agSetColumnFilter","filterParams":{"values":["Scheduled","Due Now","Overdue","Completed"]},"cellRenderer":"maintenanceStatusCellRenderer"},
        {"field":"MaintenanceDate","headerName":"Scheduled Date","width":140,"cellRenderer":"dateCellRenderer","filter":"agDateColumnFilter"},
        {"field":"NextMaintenanceDate","headerName":"Next Date","width":140,"cellRenderer":"dateCellRenderer","filter":"agDateColumnFilter"},
        {"field":"DaysUntilNext","headerName":"Days Until","width":100,"filter":"agNumberColumnFilter","cellRenderer":"daysUntilCellRenderer"},
        {"field":"TechniciansAssigned","headerName":"Technicians","width":200,"filter":"agTextColumnFilter"},
        {"field":"EstimatedHours","headerName":"Est. Hours","width":100,"filter":"agNumberColumnFilter","cellRenderer":"numberCellRenderer"},
        {"field":"ActualHours","headerName":"Actual Hours","width":100,"filter":"agNumberColumnFilter","cellRenderer":"numberCellRenderer"},
        {"field":"HoursVariancePercent","headerName":"Hours Variance %","width":140,"filter":"agNumberColumnFilter","cellRenderer":"percentageCellRenderer"},
        {"field":"MaintenanceCost","headerName":"Cost","width":120,"filter":"agNumberColumnFilter","cellRenderer":"currencyCellRenderer"},
        {"field":"MaintenanceNotes","headerName":"Notes","width":250,"filter":"agTextColumnFilter","cellRenderer":"notesCellRenderer"},
        {"field":"CompletedDate","headerName":"Completed","width":140,"cellRenderer":"dateCellRenderer","filter":"agDateColumnFilter"},
        {"field":"CreatedBy","headerName":"Created By","width":120,"filter":"agTextColumnFilter"},
        {"field":"AuditDate","headerName":"Last Updated","width":140,"cellRenderer":"dateCellRenderer","filter":"agDateColumnFilter"}
    ]','[
        {"condition":"data.Priority === ''Critical''","style":{"background-color":"#ffebee","border-left":"4px solid #f44336"}},
        {"condition":"data.Priority === ''High''","style":{"background-color":"#fff3e0","border-left":"4px solid #ff9800"}},
        {"condition":"data.MaintenanceStatus === ''Overdue''","style":{"background-color":"#ffebee","font-weight":"bold"}},
        {"condition":"data.MaintenanceStatus === ''Due Now''","style":{"background-color":"#fff8e1"}},
        {"condition":"data.MaintenanceStatus === ''Completed''","style":{"background-color":"#f1f8e9","opacity":"0.7"}}
    ]',25,NULL ,'False','True',NULL ,GETDATE(),'AUTOMATION',1)
