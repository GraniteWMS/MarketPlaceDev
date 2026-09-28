CREATE PROCEDURE [dbo].[PrescriptPickingStep200] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE @stepinput varchar(MAX) 
SELECT @stepinput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @Document varchar(20)
SELECT @Document = (SELECT [Value] FROM @input WHERE [Name] = 'Document')
UPDATE DD
SET DD.[Instruction] = 
CASE 
WHEN ExpiryRecommendation.[Date] IS NULL AND ManufactureDateRecommendation.[Date] IS NULL AND CreatedDateRecommendation.[Date] IS NULL THEN 'No Stock Found' 
WHEN ExpiryRecommendation.[Date] IS NOT NULL THEN CONCAT('Batch: ', ExpiryRecommendation.Batch,' - Expiry: ', ExpiryRecommendation.[Date])
WHEN ManufactureDateRecommendation.[Date] IS NOT NULL THEN CONCAT('Batch: ', ManufactureDateRecommendation.Batch,' - Manufacture: ', ManufactureDateRecommendation.[Date])
WHEN CreatedDateRecommendation.[Date] IS NOT NULL THEN CONCAT('Batch: ', CreatedDateRecommendation.Batch,' - Created: ', CreatedDateRecommendation.[Date])
END
FROM DocumentDetail DD
INNER JOIN Document D ON DD.Document_id = D.ID
OUTER APPLY
(SELECT TOP 1 TE.Batch, CONVERT(VARCHAR, TE.ExpiryDate, 111) AS [Date]
FROM TrackingEntity TE INNER JOIN [Location] L ON TE.Location_id = L.ID
WHERE TE.InStock = 1 AND TE.Qty > 0 AND TE.MasterItem_id = DD.Item_id AND TE.ExpiryDate IS NOT NULL AND L.ERPLocation = 'CT'
ORDER BY TE.ExpiryDate ASC) ExpiryRecommendation
OUTER APPLY
(
SELECT TOP 1 TE.Batch, CONVERT(VARCHAR, TE.ManufactureDate, 111) AS [Date]
FROM TrackingEntity TE
INNER JOIN [Location] L ON TE.Location_id = L.ID
WHERE TE.InStock = 1 AND TE.Qty > 0 AND TE.MasterItem_id = DD.Item_id AND NULLIF(TE.ManufactureDate, CONVERT(DATE, '1900-01-01')) IS NOT NULL AND L.ERPLocation = 'CT'
ORDER BY TE.ManufactureDate DESC
) ManufactureDateRecommendation
OUTER APPLY
(
SELECT TOP 1 TE.Batch, CONVERT(VARCHAR, TE.CreatedDate, 111) AS [Date]
FROM TrackingEntity TE
INNER JOIN [Location] L ON TE.Location_id = L.ID
WHERE TE.InStock = 1 AND TE.Qty > 0 AND TE.MasterItem_id = DD.Item_id AND L.ERPLocation = 'CT'
ORDER BY TE.CreatedDate DESC
) CreatedDateRecommendation
WHERE D.Number = @Document
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepinput
	SELECT * FROM @Output
