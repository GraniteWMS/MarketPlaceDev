CREATE VIEW [dbo].[WebtemplateStockTake]
AS
SELECT dbo.StockTakeLines.Barcode, 
	   Location_1.Barcode AS LocationBarcode,
	   Location_1.Name AS LocationName,
	   dbo.StockTakeLines.Count1Qty, 
	   dbo.StockTakeLines.Count2Qty, 
	   dbo.StockTakeLines.Count3Qty, 
	   dbo.StockTakeSession.Name AS Session, 
	   dbo.MasterItem.Code, 
	   dbo.MasterItem.Description
FROM  dbo.StockTakeLines INNER JOIN
         dbo.StockTakeSession ON dbo.StockTakeLines.StockTakeSession_id = dbo.StockTakeSession.ID INNER JOIN
         dbo.TrackingEntity ON dbo.StockTakeLines.TrackingEntity_id = dbo.TrackingEntity.ID INNER JOIN
         dbo.MasterItem ON dbo.TrackingEntity.MasterItem_id = dbo.MasterItem.ID INNER JOIN
         dbo.Location AS Location_1 ON dbo.StockTakeLines.OpeningLocation_id = Location_1.ID INNER JOIN
         dbo.Location ON dbo.TrackingEntity.Location_id = dbo.Location.ID LEFT OUTER JOIN
         dbo.CarryingEntity ON dbo.TrackingEntity.BelongsToEntity_id = dbo.CarryingEntity.ID LEFT OUTER JOIN
         dbo.Location AS Location_2 ON dbo.StockTakeLines.Location_id = Location_2.ID
WHERE TrackingEntity.InStock = 1 AND StockTakeLines.Status NOT IN ('APPROVED', 'COMPLETED')
