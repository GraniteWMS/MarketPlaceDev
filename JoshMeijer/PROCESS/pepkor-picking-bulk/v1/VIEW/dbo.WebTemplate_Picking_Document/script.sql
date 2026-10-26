CREATE VIEW [dbo].[WebTemplate_Picking_Document]
AS
SELECT Number AS DocumentNumber, CONVERT(VARCHAR, ExpectedDate, 111) AS ExpectedDate FROM [Document] 
INNER JOIN Custom_VW_DocumentERPLocations ON Custom_VW_DocumentERPLocations.DocumentID = Document.ID
WHERE [Type] = 'ORDER' AND [Status] NOT IN ('CANCELLED', 'COMPLETE') 
AND Custom_VW_DocumentERPLocations.ERPLocation = 'FG'
