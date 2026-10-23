CREATE VIEW [dbo].[MasterItemAlias_View]
	AS 
SELECT ROW_NUMBER() OVER (ORDER BY [GraniteDatabase].dbo.MasterItem.ID) AS ID, 
CAST([PINTST].dbo.ICIOTH.MANITEMNO as varchar(16)) COLLATE SQL_Latin1_General_CP1_CI_AS AS Code, 
CAST([PINTST].dbo.ICUNIT.UNIT as varchar(16)) COLLATE SQL_Latin1_General_CP1_CI_AS AS UOM, 
[PINTST].dbo.ICUNIT.CONVERSION AS Conversion, CAST(1 as bit)as IsActive, 
GETDATE() as AuditDate, '' as AuditUser, 
[GraniteDatabase].dbo.MasterItem.ID AS MasterItem_id,NULL as ERPIdentification,0 as Version
FROM         [PINTST].dbo.ICIOTH RIGHT OUTER JOIN
                      [PINTST].dbo.ICUNIT ON [PINTST].dbo.ICIOTH.UNIT COLLATE SQL_Latin1_General_CP1_CI_AS = [PINTST].dbo.ICUNIT.UNIT AND 
                      [PINTST].dbo.ICIOTH.ITEMNO COLLATE SQL_Latin1_General_CP1_CI_AS = [PINTST].dbo.ICUNIT.ITEMNO RIGHT OUTER JOIN
                      [GraniteDatabase].dbo.MasterItem RIGHT OUTER JOIN
                      [PINTST].dbo.ICITEM ON [GraniteDatabase].dbo.MasterItem.Code COLLATE SQL_Latin1_General_CP1_CI_AS = [PINTST].dbo.ICITEM.ITEMNO ON 
                      [PINTST].dbo.ICUNIT.ITEMNO COLLATE SQL_Latin1_General_CP1_CI_AS = [PINTST].dbo.ICITEM.ITEMNO
WHERE     ([GraniteDatabase].dbo.MasterItem.ID IS NOT NULL) AND ([PINTST].dbo.ICIOTH.MANITEMNO IS NOT NULL)
UNION
SELECT  * FROM [GraniteDatabase].dbo.MasterItemAlias
