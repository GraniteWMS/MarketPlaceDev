INSERT INTO [dbo].[DataGrid]
  ([Group]
   ,[Name]
   ,[SQLView]
   ,[GridDefinition]
   ,[UserGroup_id]
   ,[User_id]
   ,[AuditDate]
   ,[AuditUser]
   ,[Version]
   ,[isApplicationGrid]
   ,[isCustomGrid])
   VALUES
   ('DocumentTracking'
    ,'DocumentTrackingLog'
    ,'DataGrid_Custom_DocumentTrackingLog'
    ,'[{"field":"Document","width":140,"filter":"agTextColumnFilter"},{"headerName":"Comment","field":"Comment","width":300,"filter":"agTextColumnFilter"},{"field":"TrackingStatus","width":120,"filter":"agTextColumnFilter"},{"field":"Process","width":180,"filter":"agTextColumnFilter"},{"field":"User","width":120,"filter":"agTextColumnFilter"},{"field":"ActivityDate","width":180,"filter":"agDateColumnFilter"}]'
    ,NULL
    ,NULL
    ,CASE WHEN getdate() IS NULL THEN CURRENT_TIMESTAMP ELSE getdate() END 
    ,'0'
    ,1
    ,0
    ,1)