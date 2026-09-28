CREATE VIEW [dbo].[Integration_Accpac_BomH] as
SELECT *
FROM [TSTDAT].dbo.ICBOMH
WHERE [ICBOMH].INACTIVE = 0
