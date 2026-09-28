CREATE PROCEDURE WebtemplateSpotCheckConfirmation
	@Cage varchar(100),
	@Barcode varchar(50)
AS
SELECT MasterItem.Code, MasterItem.Description, Location.Name, TrackingEntity.Barcode 
FROM	TrackingEntity  
		INNER JOIN Location ON TrackingEntity.Location_id = Location.ID
		INNER JOIN MasterItem On TrackingEntity.MasterItem_id = MasterItem.ID
WHERE	(MasterItem.Code = @Barcode OR Location.Barcode = @Barcode OR Location.Name = @Barcode OR TrackingEntity.Barcode = @Barcode)
		AND InStock = 1
		AND Location.Category = @Cage
