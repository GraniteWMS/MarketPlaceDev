CREATE VIEW [dbo].[WebTemplate_ReplenishFromEthicalReceivingBox_FromTrackingEntity]
AS
SELECT
TE.Barcode,
MI.Code AS ItemCode,
MI.[Description] AS ItemDescription,
CONVERT(BIGINT, TE.Qty) AS Qty,
CE.Barcode AS Box
FROM TrackingEntity TE
INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
INNER JOIN CarryingEntity CE ON TE.BelongsToEntity_id = CE.ID
WHERE TE.InStock = 1 AND TE.OnHold = 0 AND Qty > 0 AND ISNULL(CE.PhysicalType, '') = 'ETHL_REC'
