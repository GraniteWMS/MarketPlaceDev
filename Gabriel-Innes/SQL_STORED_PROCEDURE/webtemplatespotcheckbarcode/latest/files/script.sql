CREATE PROCEDURE WebtemplateSpotCheckBarcode
	@Session varchar(50)
AS
SELECT	MasterItemCode MasterItem, 
		Location.Name Location,
		StockTakeLines.Barcode TrackingEntity
FROM	StockTakeLines 
		INNER JOIN StockTakeSession ON StockTakeLines.StockTakeSession_id = StockTakeSession.ID
		INNER JOIN Location ON OpeningLocation_id = Location.ID
WHERE StockTakeSession.Name = @Session
order by MasterItem, Location
