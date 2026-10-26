CREATE PROCEDURE [dbo].[PrescriptPickingDocument] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX)
DECLARE @stepinput varchar(MAX) 
SELECT @stepinput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @SortTable TABLE (
MasterItemID bigint,
Code varchar(30),
SortOrder int
)
DECLARE @Document_id bigint
DECLARE @Document varchar(20)
SELECT @Document_id = ID FROM Document WHERE Number = @stepinput
SELECT @Document = (SELECT Number FROM Document WHERE ID = @Document_id )
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
ORDER BY TE.ManufactureDate ASC
) ManufactureDateRecommendation
OUTER APPLY
(
SELECT TOP 1 TE.Batch, CONVERT(VARCHAR, TE.CreatedDate, 111) AS [Date]
FROM TrackingEntity TE
INNER JOIN [Location] L ON TE.Location_id = L.ID
WHERE TE.InStock = 1 AND TE.Qty > 0 AND TE.MasterItem_id = DD.Item_id AND L.ERPLocation = 'CT'
ORDER BY TE.CreatedDate ASC
) CreatedDateRecommendation
WHERE D.Number = @Document
IF @Document like 'PS%'
BEGIN
	UPDATE DocumentDetail
	SET FromLocation = DocumentDetail_1.FromLocation
	FROM DocumentDetail INNER JOIN
	DocumentDetail AS DocumentDetail_1 ON DocumentDetail.LinkedDetail_id = DocumentDetail_1.ID
	WHERE (DocumentDetail.Document_id = @Document_id)
END
IF ISNULL(@Document_id, 0) <> 0
BEGIN
	INSERT INTO @SortTable (Code, SortOrder)
	EXEC Utility_GetSortOrder @stepinput
	UPDATE @SortTable 
	SET MasterItemID = MasterItem.ID
	FROM @SortTable st INNER JOIN MasterItem
	ON MasterItem.Code = st.Code
	WHERE st.Code = MasterItem.Code
	
	UPDATE DocumentDetail
	SET Comment = SortOrder
	FROM @SortTable st
	WHERE Document_id = @Document_id AND Item_id = st.MasterItemID
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepinput
	SELECT * FROM @Output
