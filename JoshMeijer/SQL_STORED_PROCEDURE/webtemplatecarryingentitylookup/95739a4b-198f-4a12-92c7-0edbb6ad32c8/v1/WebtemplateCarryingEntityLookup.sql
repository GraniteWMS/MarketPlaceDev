CREATE Procedure WebtemplateCarryingEntityLookup
	@Barcode varchar(30)
AS
SELECT	CarryingEntity.Barcode,
		TrackingEntity.Barcode AS TrackingEntityBarcode, 
		TrackingEntity.Qty,
		TrackingEntity.InStock,
		TrackingEntity.OnHold,
		TrackingEntity.Batch,
		TrackingEntity.SerialNumber,
		TrackingEntity.ExpiryDate,
		MasterItem.Code, 
		MasterItem.Description, 
		Location.Barcode AS LocationBarcode,
		Location.Name AS LocationName
FROM	CarryingEntity 
		INNER JOIN TrackingEntity ON CarryingEntity.ID = TrackingEntity.BelongsToEntity_id
		INNER JOIN MasterItem ON TrackingEntity.MasterItem_id = MasterItem.ID 
		INNER JOIN Location ON CarryingEntity.Location_id = Location.ID
WHERE CarryingEntity.Barcode = @Barcode
