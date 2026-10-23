CREATE VIEW [dbo].[Custom_StockTakeCountAlias]
AS
SELECT TrackingEntity.Barcode AS TrackingEntityBarcode, 
	MasterItem.ID AS MasterItemID, 
	MasterItemAlias.Code AS Alias
FROM TrackingEntity INNER JOIN MasterItem ON TrackingEntity.MasterItem_id = MasterItem.ID LEFT JOIN
							MasterItemAlias ON MasterItem.ID = MasterItemAlias.MasterItem_id
