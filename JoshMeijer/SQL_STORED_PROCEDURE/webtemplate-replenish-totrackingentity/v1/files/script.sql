CREATE PROCEDURE Webtemplate_Replenish_ToTrackingEntity
	@FromTrackingEntity varchar(50)
AS
DECLARE @FromTrackingEntityItem_id bigint = (SELECT MasterItem_id FROM TrackingEntity WHERE Barcode = @FromTrackingEntity)
SELECT
TrackingEntity.Barcode AS TEBarcode
,[Location].Barcode AS [Location]
FROM TrackingEntity
INNER JOIN [Location] ON TrackingEntity.Location_id = [Location].ID
WHERE MasterItem_id = @FromTrackingEntityItem_id
AND TrackingEntity.Barcode <> @FromTrackingEntity
ORDER BY TrackingEntity.Barcode DESC