CREATE VIEW WebTemplate_BatchLookup_DetailsHeader
AS
	SELECT
	TE.Batch,
	MI.Code AS ItemCode,
	MI.[Description] AS ItemDescription,
	CONVERT(DECIMAL(19, 2), SUM(TE.Qty)) AS Qty
	FROM TrackingEntity TE
	INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
	WHERE TE.InStock = 1 AND TE.Qty > 0 AND TE.Batch IS NOT NULL
	GROUP BY
	TE.Batch,
	MI.Code,
	MI.[Description]	
