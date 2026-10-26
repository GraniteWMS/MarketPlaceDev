CREATE PROCEDURE [dbo].[WebtemplateUncosumeTrackingEntity]
	@Document varchar(30)
AS

SELECT	TrackingEntity.Barcode [TE Barcode], 
		Location.Name AS [TE Location], 
		MasterItem.Code AS MasterItemCode,
		ActionQty AS [Comsumed Qty], 
		TrackingEntity.Qty AS [TE Qty]
FROM	[Transaction] 
		INNER JOIN TrackingEntity ON [Transaction].TrackingEntity_id = TrackingEntity.ID 
		INNER JOIN Document ON [Transaction].Document_id = Document.ID 
		INNER JOIN Location ON TrackingEntity.Location_id = Location.ID 
		INNER JOIN MasterItem ON TrackingEntity.MasterItem_id = MasterItem.ID
WHERE	[Transaction].Type = 'CONSUME'	
		AND Document.Number = @Document
