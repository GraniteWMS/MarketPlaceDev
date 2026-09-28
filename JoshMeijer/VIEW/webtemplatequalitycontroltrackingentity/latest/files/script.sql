CREATE VIEW [dbo].[WebtemplateQualitycontrolTrackingEntity] AS 
SELECT TrackingEntity.Barcode, TrackingEntity.Batch, L.[Name] LocationName
FROM [Location] L
	INNER JOIN TrackingEntity ON L.ID = TrackingEntity.Location_id
