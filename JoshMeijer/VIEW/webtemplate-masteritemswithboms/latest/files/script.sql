CREATE VIEW [dbo].[WebTemplate_MasterItemswithBOMS]
AS
SELECT        Code, [Description], [Category], 
BOMNO as BOM, REMARK,UNIT
FROM [MasterItem] INNER JOIN 
Integration_Accpac_BomH BOM ON BOM.ITEMNO COLLATE Latin1_General_CI_AS = Code
