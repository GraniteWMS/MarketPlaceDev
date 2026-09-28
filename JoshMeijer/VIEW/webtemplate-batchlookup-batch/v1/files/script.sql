CREATE VIEW WebTemplate_BatchLookup_Batch
AS
	SELECT DISTINCT
	Batch
	FROM TrackingEntity
	WHERE InStock = 1 AND Qty > 0 AND Batch IS NOT NULL
