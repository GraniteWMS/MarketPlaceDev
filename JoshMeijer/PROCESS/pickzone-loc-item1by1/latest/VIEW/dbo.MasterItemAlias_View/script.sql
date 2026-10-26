CREATE VIEW [dbo].[MasterItemAlias_View]
	AS 
SELECT ROW_NUMBER() OVER (ORDER BY [GraniteDatabase].dbo.MasterItem.ID) AS ID, 
CAST([PINDAT].dbo.ICIOTH.MANITEMNO as varchar(16)) COLLATE SQL_Latin1_General_CP1_CI_AS AS Code, 
CAST([PINDAT].dbo.ICUNIT.UNIT as varchar(16)) COLLATE SQL_Latin1_General_CP1_CI_AS AS UOM, 
[PINDAT].dbo.ICUNIT.CONVERSION AS Conversion, CAST(1 as bit)as IsActive, 
GETDATE() as AuditDate, '' as AuditUser, 
[GraniteDatabase].dbo.MasterItem.ID AS MasterItem_id,NULL as ERPIdentification,0 as Version
FROM         [PINDAT].dbo.ICIOTH RIGHT OUTER JOIN
                      [PINDAT].dbo.ICUNIT ON [PINDAT].dbo.ICIOTH.UNIT COLLATE SQL_Latin1_General_CP1_CI_AS = [PINDAT].dbo.ICUNIT.UNIT AND 
                      [PINDAT].dbo.ICIOTH.ITEMNO COLLATE SQL_Latin1_General_CP1_CI_AS = [PINDAT].dbo.ICUNIT.ITEMNO RIGHT OUTER JOIN
                      [GraniteDatabase].dbo.MasterItem RIGHT OUTER JOIN
                      [PINDAT].dbo.ICITEM ON [GraniteDatabase].dbo.MasterItem.Code COLLATE SQL_Latin1_General_CP1_CI_AS = [PINDAT].dbo.ICITEM.ITEMNO ON 
                      [PINDAT].dbo.ICUNIT.ITEMNO COLLATE SQL_Latin1_General_CP1_CI_AS = [PINDAT].dbo.ICITEM.ITEMNO
WHERE     ([GraniteDatabase].dbo.MasterItem.ID IS NOT NULL) AND ([PINDAT].dbo.ICIOTH.MANITEMNO IS NOT NULL)
UNION
SELECT  * FROM [GraniteDatabase].dbo.MasterItemAlias
