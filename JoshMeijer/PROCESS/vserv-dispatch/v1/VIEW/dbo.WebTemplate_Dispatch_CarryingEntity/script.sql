CREATE VIEW [dbo].[WebTemplate_Dispatch_CarryingEntity]
AS
SELECT 
CE.Barcode, 
L.Barcode AS [Location],
CE.CreateDate AS [Date]
FROM CarryingEntity CE
INNER JOIN [Location] L ON CE.Location_id = L.ID
WHERE (CE.Barcode LIKE 'BOX%' OR CE.Barcode LIKE 'LS%') AND L.Barcode <> 'DISPATCH'
AND EXISTS(SELECT ID FROM TrackingEntity WHERE BelongsToEntity_id = CE.ID)
