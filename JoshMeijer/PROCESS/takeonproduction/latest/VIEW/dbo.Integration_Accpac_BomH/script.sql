CREATE VIEW [dbo].[Integration_Accpac_BomH] as
SELECT *
FROM [FNADAT].dbo.ICBOMH
WHERE [ICBOMH].INACTIVE = 0
