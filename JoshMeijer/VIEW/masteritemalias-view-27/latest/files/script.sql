CREATE VIEW [dbo].[MasterItemAlias_View]
	AS 
SELECT 
ROW_NUMBER() OVER (ORDER BY [GraniteTest].dbo.MasterItem.ID) AS ID, 
StkItem.ucIIEANCode AS Code, 
'EACH' AS UOM, 
CONVERT(DECIMAL(19, 4), 1) AS Conversion, 
CONVERT(BIT, 1) AS IsActive, 
GETDATE() AS AuditDate, 
'' AS AuditUser, 
[GraniteTest].dbo.MasterItem.ID AS MasterItem_id, 
NULL AS ERPIdentification, 
CONVERT(SMALLINT, 0) AS [Version]
FROM [VETSERV_PE].dbo.StkItem WITH (NOLOCK) 
INNER JOIN [GraniteTest].dbo.MasterItem WITH (NOLOCK) 
ON [VETSERV_PE].dbo.StkItem.Code = [GraniteTest].dbo.MasterItem.Code COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE StkItem.ucIIEANCode IS NOT NULL
