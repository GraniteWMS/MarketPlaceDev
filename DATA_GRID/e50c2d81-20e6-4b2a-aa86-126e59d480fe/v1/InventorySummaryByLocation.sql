INSERT INTO [DataGrid] ([Group],[Name],[SQLView],[GridDefinition],[RowStyleRules],[PageSize],[UserGroup_id],[isApplicationGrid],[isCustomGrid],[User_id],[AuditDate],[AuditUser],[Version]) 
VALUES('CustomReports','InventorySummaryByLocation','DataGrid_InventorySummaryByLocation','[
        {"field":"ID","width":60,"hide":true,"filter":"agNumberColumnFilter"},
        {"field":"LocationName","headerName":"Location Name","width":200,"filter":"agTextColumnFilter","cellRenderer":"selectRecord"},
        {"field":"LocationBarcode","headerName":"Location Code","width":150,"filter":"agTextColumnFilter"},
        {"field":"LocationType","headerName":"Type","width":120,"filter":"agTextColumnFilter"},
        {"field":"ItemCode","headerName":"Item Code","width":150,"filter":"agTextColumnFilter"},
        {"field":"ItemDescription","headerName":"Item Description","width":250,"filter":"agTextColumnFilter"},
        {"field":"UOM","headerName":"UOM","width":80,"filter":"agTextColumnFilter"},
        {"field":"TotalQuantity","headerName":"Total Qty","width":120,"filter":"agNumberColumnFilter","cellRenderer":"numberCellRenderer"},
        {"field":"TrackingEntityCount","headerName":"Entity Count","width":120,"filter":"agNumberColumnFilter"},
        {"field":"LastActivityDate","headerName":"Last Activity","width":140,"cellRenderer":"dateCellRenderer","filter":"agDateColumnFilter"},
        {"field":"AverageValue","headerName":"Avg Value","width":120,"filter":"agNumberColumnFilter","cellRenderer":"currencyCellRenderer"},
        {"field":"StockStatus","headerName":"Status","width":120,"filter":"agSetColumnFilter","filterParams":{"values":["Empty","Low Stock","Normal"]},"cellRenderer":"statusCellRenderer"}
    ]','',50,NULL ,'False','True',NULL ,GETDATE(),'AUTOMATION',1)
