CREATE PROCEDURE WebtemplateStockTakeLocation
	@Session varchar(30),
	@Count int
AS

IF (@Count = 1)
	BEGIN
		SELECT DISTINCT Location.Barcode, Location.Name
		FROM	dbo.StockTakeLines INNER JOIN
				dbo.StockTakeSession ON dbo.StockTakeLines.StockTakeSession_id = dbo.StockTakeSession.ID INNER JOIN
				dbo.Location ON dbo.StockTakeLines.OpeningLocation_id = Location.ID
		WHERE Count1Qty IS NULL AND StockTakeSession.Name = @Session
	END
ELSE IF (@Count = 2)
	BEGIN
		SELECT DISTINCT Location.Barcode, Location.Name
		FROM	dbo.StockTakeLines INNER JOIN
				dbo.StockTakeSession ON dbo.StockTakeLines.StockTakeSession_id = dbo.StockTakeSession.ID INNER JOIN
				dbo.Location ON dbo.StockTakeLines.OpeningLocation_id = Location.ID
		WHERE Count2Qty IS NULL AND StockTakeSession.Name = @Session
	END
ELSE IF (@Count = 3)
	BEGIN
		SELECT DISTINCT Location.Barcode, Location.Name
		FROM	dbo.StockTakeLines INNER JOIN
				dbo.StockTakeSession ON dbo.StockTakeLines.StockTakeSession_id = dbo.StockTakeSession.ID INNER JOIN
				dbo.Location ON dbo.StockTakeLines.OpeningLocation_id = Location.ID
		WHERE Count3Qty IS NULL AND StockTakeSession.Name = @Session
	END

