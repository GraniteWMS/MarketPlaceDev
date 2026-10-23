CREATE PROCEDURE [dbo].[WebTemplate_Pickslipsummaryinfo]
@Number NVARCHAR(100)  
AS
BEGIN 
SELECT	DISTINCT Document_1.Number AS SalesOrder, 
		Document_1.TradingPartnerCode
FROM  dbo.[Document] INNER JOIN
         dbo.DocumentDetail ON dbo.[Document].ID = dbo.DocumentDetail.Document_id INNER JOIN
         dbo.Type ON dbo.[Document].Type = dbo.Type.Name INNER JOIN
         dbo.DocumentDetail AS DocumentDetail_1 ON dbo.DocumentDetail.LinkedDetail_id = DocumentDetail_1.ID INNER JOIN
         dbo.[Document] AS Document_1 ON DocumentDetail_1.Document_id = Document_1.ID INNER JOIN
         dbo.Status ON dbo.[Document].Status = dbo.Status.Name 
WHERE (dbo.Type.Name = 'PICKSLIP') AND Document.Number = @Number
 
END
