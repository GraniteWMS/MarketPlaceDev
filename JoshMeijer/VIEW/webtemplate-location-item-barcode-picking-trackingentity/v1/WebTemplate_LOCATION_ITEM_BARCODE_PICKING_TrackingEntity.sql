CREATE VIEW [dbo].[WebTemplate_LOCATION_ITEM_BARCODE_PICKING_TrackingEntity]
AS
SELECT	TE.Barcode, L.Name AS LocationName, TE.Qty, MI.Code
FROM	TrackingEntity TE INNER JOIN
		Location L ON L.ID = TE.Location_id INNER JOIN 
		MasterItem MI ON TE.MasterItem_id = MI.ID
WHERE	TE.Qty > 0

