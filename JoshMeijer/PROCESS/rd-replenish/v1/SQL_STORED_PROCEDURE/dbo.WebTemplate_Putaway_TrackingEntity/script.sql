CREATE PROCEDURE [dbo].[WebTemplate_Putaway_TrackingEntity]
@TrackingEntityBarcode NVARCHAR(100)  
AS
BEGIN
DECLARE @TrackingEntity_ID BIGINT
DECLARE @MasterItem_ID BIGINT
SELECT @MasterItem_ID = MI.ID FROM TrackingEntity TE INNER JOIN
MasterItem MI ON TE.MasterItem_id = MI.ID
WHERE TE.Barcode = @TrackingEntityBarcode
SELECT L.Barcode, 'Stocked' as [Status],TE.Qty
FROM TrackingEntity TE INNER JOIN Location L
ON TE.Location_id = L.ID
WHERE TE.Qty >0 
AND L.NonStock = 0 
AND TE.InStock = 1
AND TE.MasterItem_id = @MasterItem_ID
UNION
SELECT TOP 3 Barcode as [Location], 'Empty' as [Status],0 as Qty
FROM API_QueryLocations
WHERE isnull(Inventory,0) <1 AND NonStock = 0
END
