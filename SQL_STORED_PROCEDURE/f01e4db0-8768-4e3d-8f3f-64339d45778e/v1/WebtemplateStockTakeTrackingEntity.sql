CREATE PROCEDURE WebtemplateStockTakeTrackingEntity
	@Session varchar(30),
	@Count int,
	@Location varchar(30)
AS

IF (@Count = 1)
	BEGIN
		SELECT DISTINCT TrackingEntity.Barcode, MasterItem.Code, MasterItem.Description
		FROM	dbo.StockTakeLines INNER JOIN
				dbo.StockTakeSession ON dbo.StockTakeLines.StockTakeSession_id = dbo.StockTakeSession.ID INNER JOIN
				dbo.Location ON dbo.StockTakeLines.OpeningLocation_id = Location.ID INNER JOIN 
				dbo.TrackingEntity ON dbo.StockTakeLines.TrackingEntity_id = TrackingEntity.ID INNER JOIN
				dbo.MasterItem on dbo.StockTakeLines.MasterItem_id = dbo.MasterItem.ID
		WHERE Count1Qty IS NULL AND StockTakeSession.Name = @Session and Location.Barcode = @Location
	END
ELSE IF (@Count = 2)
	BEGIN
		SELECT DISTINCT TrackingEntity.Barcode, MasterItem.Code, MasterItem.Description
		FROM	dbo.StockTakeLines INNER JOIN
				dbo.StockTakeSession ON dbo.StockTakeLines.StockTakeSession_id = dbo.StockTakeSession.ID INNER JOIN
				dbo.Location ON dbo.StockTakeLines.OpeningLocation_id = Location.ID INNER JOIN 
				dbo.TrackingEntity ON dbo.StockTakeLines.TrackingEntity_id = TrackingEntity.ID INNER JOIN
				dbo.MasterItem on dbo.StockTakeLines.MasterItem_id = dbo.MasterItem.ID
		WHERE Count2Qty IS NULL AND StockTakeSession.Name = @Session and Location.Barcode = @Location
	END
ELSE IF (@Count = 3)
	BEGIN
		SELECT DISTINCT TrackingEntity.Barcode, MasterItem.Code, MasterItem.Description
		FROM	dbo.StockTakeLines INNER JOIN
				dbo.StockTakeSession ON dbo.StockTakeLines.StockTakeSession_id = dbo.StockTakeSession.ID INNER JOIN
				dbo.Location ON dbo.StockTakeLines.OpeningLocation_id = Location.ID INNER JOIN 
				dbo.TrackingEntity ON dbo.StockTakeLines.TrackingEntity_id = TrackingEntity.ID INNER JOIN
				dbo.MasterItem on dbo.StockTakeLines.MasterItem_id = dbo.MasterItem.ID
		WHERE Count3Qty IS NULL AND StockTakeSession.Name = @Session and Location.Barcode = @Location
	END

