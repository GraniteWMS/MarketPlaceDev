CREATE VIEW WebTemplate_BatchLookup_DetailsDetail
AS
	SELECT
	TE.Batch,
	TE.Barcode,
	MI.Code AS ItemCode,
	MI.[Description] AS ItemDescription,
	CONVERT(DECIMAL(19, 2), TE.Qty) AS Qty
	FROM TrackingEntity TE
	INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
	WHERE TE.InStock = 1 AND TE.Qty > 0 AND TE.Batch IS NOT NULL	
