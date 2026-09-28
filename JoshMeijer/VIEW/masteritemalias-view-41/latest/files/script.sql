CREATE VIEW [dbo].[MasterItemAlias_View]
	AS 
SELECT 
ROW_NUMBER() OVER (ORDER BY MasterItem_id) AS ID
,*
FROM
(
SELECT 
StkItem.ucIIEANCode AS Code, 
'Unit' AS UOM, 
CONVERT(DECIMAL(19, 4), 1) AS Conversion, 
CONVERT(BIT, 1) AS IsActive, 
GETDATE() AS AuditDate, 
'AUTOMATION' AS AuditUser, 
[GraniteTest].dbo.MasterItem.ID AS MasterItem_id, 
NULL AS ERPIdentification, 
CONVERT(SMALLINT, 0) AS [Version]
FROM [VETSERV_PE].dbo.StkItem WITH (NOLOCK) 
INNER JOIN [GraniteTest].dbo.MasterItem WITH (NOLOCK) 
ON [VETSERV_PE].dbo.StkItem.Code = [GraniteTest].dbo.MasterItem.Code COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE StkItem.ucIIEANCode IS NOT NULL
UNION 
SELECT DISTINCT 
[Code]
,[UOM]
,[Conversion]
,CONVERT(BIT, 1) AS IsActive
,GETDATE() AS AuditDate 
,'AUTOMATION' AS AuditUser
,[MasterItem_id]
,NULL AS [ERPIdentification]
,CONVERT(SMALLINT, 0) AS [Version]
FROM MasterItemAlias WHERE ISNULL(Code, '') <> ''
) Aliases
