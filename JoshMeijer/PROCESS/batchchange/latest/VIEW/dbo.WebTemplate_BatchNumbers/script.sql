CREATE VIEW [dbo].[WebTemplate_BatchNumbers]
AS
SELECT        Code,Batch,COUNT(*) as PalletCount
FROM TrackingEntity 
INNER JOIN MasterItem ON TrackingEntity.MasterItem_id = MasterItem.ID
GROUP BY MasterItem.Code, TrackingEntity.Batch
