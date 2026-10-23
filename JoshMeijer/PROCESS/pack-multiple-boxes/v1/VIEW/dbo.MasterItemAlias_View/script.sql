CREATE VIEW [dbo].[MasterItemAlias_View]
	AS 
	SELECT ROW_NUMBER() OVER (ORDER BY dbo.MasterItem.ID) AS ID, 
CAST([NYOAMZ].dbo.ICIOTH.MANITEMNO as varchar(16)) COLLATE SQL_Latin1_General_CP1_CI_AS AS Code, 
CAST([NYOAMZ].dbo.ICUNIT.UNIT as varchar(16)) COLLATE SQL_Latin1_General_CP1_CI_AS AS UOM, 
[NYOAMZ].dbo.ICUNIT.CONVERSION AS Conversion, CAST(1 as bit)as IsActive, 
GETDATE() as AuditDate, '' as AuditUser, 
dbo.MasterItem.ID AS MasterItem_id,NULL as ERPIdentification,0 as Version
FROM         [NYOAMZ].dbo.ICIOTH RIGHT OUTER JOIN
                      [NYOAMZ].dbo.ICUNIT ON [NYOAMZ].dbo.ICIOTH.UNIT COLLATE SQL_Latin1_General_CP1_CI_AS = [NYOAMZ].dbo.ICUNIT.UNIT AND 
                      [NYOAMZ].dbo.ICIOTH.ITEMNO COLLATE SQL_Latin1_General_CP1_CI_AS = [NYOAMZ].dbo.ICUNIT.ITEMNO RIGHT OUTER JOIN
                      dbo.MasterItem RIGHT OUTER JOIN
                      [NYOAMZ].dbo.ICITEM ON dbo.MasterItem.Code COLLATE SQL_Latin1_General_CP1_CI_AS = [NYOAMZ].dbo.ICITEM.ITEMNO ON 
                      [NYOAMZ].dbo.ICUNIT.ITEMNO COLLATE SQL_Latin1_General_CP1_CI_AS = [NYOAMZ].dbo.ICITEM.ITEMNO
WHERE     (dbo.MasterItem.ID IS NOT NULL) AND ([NYOAMZ].dbo.ICIOTH.MANITEMNO IS NOT NULL)
UNION
SELECT  * FROM dbo.MasterItemAlias
