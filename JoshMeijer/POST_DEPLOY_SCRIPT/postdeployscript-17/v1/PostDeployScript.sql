INSERT INTO [Audit] (AuditDate, AuditTime, [User], RecordID, RecordVersion, [Application], TableName, ChangeType, ColumnName, PreviousValue, NewValue)
SELECT GETDATE(), GETDATE(), 'AUTOMATION', ID, [Version] + 1, 'CUSTODIAN', 'DataGrid', 'UPDATE', 'GridDefinition', GridDefinition, 
'[{"headerName":"Line","field":"LineNumber","width":40,"filter":"agTextColumnFilter"},{"field":"Code","width":100,"filter":"agTextColumnFilter"},{"field":"Description","width":200,"filter":"agTextColumnFilter"},{"field":"ActionQty","width":120,"filter":"agTextColumnFilter"},{"field":"Qty","width":60,"filter":"agTextColumnFilter"},{"field":"Outstanding","width":120,"filter":"agTextColumnFilter"},{"field":"QtyOnHand","width":120,"filter":"agTextColumnFilter"},{"field":"Instruction","width":200,"filter":"agTextColumnFilter"},{"field":"Comment","width":200,"filter":"agTextColumnFilter"}]'
FROM DataGrid
WHERE [Group] = 'DocumentProgress' AND [Name] = 'OrderDetailDocumentProgress'

UPDATE DataGrid
SET GridDefinition = '[{"headerName":"Line","field":"LineNumber","width":40,"filter":"agTextColumnFilter"},{"field":"Code","width":100,"filter":"agTextColumnFilter"},{"field":"Description","width":200,"filter":"agTextColumnFilter"},{"field":"ActionQty","width":120,"filter":"agTextColumnFilter"},{"field":"Qty","width":60,"filter":"agTextColumnFilter"},{"field":"Outstanding","width":120,"filter":"agTextColumnFilter"},{"field":"QtyOnHand","width":120,"filter":"agTextColumnFilter"},{"field":"Instruction","width":200,"filter":"agTextColumnFilter"},{"field":"Comment","width":200,"filter":"agTextColumnFilter"}]',
    [Version] = [Version] + 1
WHERE [Group] = 'DocumentProgress' AND [Name] = 'OrderDetailDocumentProgress'