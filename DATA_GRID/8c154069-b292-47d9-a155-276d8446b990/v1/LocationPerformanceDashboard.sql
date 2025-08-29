INSERT INTO [DataGrid] ([Group],[Name],[SQLView],[GridDefinition],[RowStyleRules],[PageSize],[UserGroup_id],[isApplicationGrid],[isCustomGrid],[User_id],[AuditDate],[AuditUser],[Version]) 
VALUES('Analytics','LocationPerformanceDashboard','DataGrid_LocationPerformanceDashboard','[
        {"field":"ID","headerName":"ID","width":80,"hide":true},
        {"field":"LocationName","headerName":"Location","width":200,"pinned":"left"},
        {"field":"LocationCode","headerName":"Code","width":120},
        {"field":"TotalTrackingEntities","headerName":"Total Items","width":120,"filter":"agNumberColumnFilter"},
        {"field":"InStockEntities","headerName":"In Stock","width":120,"filter":"agNumberColumnFilter"},
        {"field":"UtilizationPercentage","headerName":"Utilization %","width":130,"filter":"agNumberColumnFilter","cellRenderer":"percentageCellRenderer"},
        {"field":"UtilizationLevel","headerName":"Utilization Level","width":160,"filter":"agSetColumnFilter"},
        {"field":"ActivityScore","headerName":"Activity Score","width":130,"filter":"agNumberColumnFilter"},
        {"field":"PerformanceRank","headerName":"Rank","width":80,"filter":"agNumberColumnFilter"},
        {"field":"CompositeScore","headerName":"Composite Score","width":140,"filter":"agNumberColumnFilter","cellRenderer":"numberCellRenderer"},
        {"field":"RiskLevel","headerName":"Risk Level","width":120,"filter":"agSetColumnFilter","cellRenderer":"riskLevelCellRenderer"},
        {"field":"PerformanceCategory","headerName":"Performance","width":150,"filter":"agSetColumnFilter","cellRenderer":"performanceCellRenderer"}
    ]','[
        {"condition":"data.RiskLevel === ''High Risk''","style":{"background-color":"#ffebee","border-left":"4px solid #f44336"}},
        {"condition":"data.RiskLevel === ''Medium Risk''","style":{"background-color":"#fff3e0","border-left":"4px solid #ff9800"}},
        {"condition":"data.PerformanceCategory === ''Top Performer''","style":{"background-color":"#e8f5e8","border-left":"4px solid #4caf50"}},
        {"condition":"data.PerformanceCategory === ''Needs Attention''","style":{"background-color":"#ffebee","font-weight":"bold"}}
    ]',25,NULL ,'False','True',NULL ,GETDATE(),'AUTOMATION',1)
