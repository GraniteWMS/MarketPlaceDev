CREATE VIEW [dbo].[MasterItemAlias_View]
AS 
SELECT 
	ROW_NUMBER() OVER (ORDER BY MI.ID) AS ID,
    MIA.Code, 
    MIA.UOM, 
    MIA.Conversion, 
    MIA.IsActive , 
    MI.ID AS MasterItem_id,
    MIA.AuditDate AuditDate, 
    MIA.AuditUser, 
	MIA.[Version], 
    MIA.ERPIdentification,
	MI.Code AS [MasterItemCode],
	MI.[Description] AS [MasterItemDescription]
FROM MasterItemAlias MIA
INNER JOIN dbo.MasterItem AS MI ON MIA.MasterItem_id = Mi.ID
