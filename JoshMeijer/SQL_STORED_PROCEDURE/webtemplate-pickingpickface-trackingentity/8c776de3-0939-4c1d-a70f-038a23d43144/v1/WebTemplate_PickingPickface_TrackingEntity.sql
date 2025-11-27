




CREATE PROCEDURE WebTemplate_PickingPickface_TrackingEntity 
	
	@Document varchar(50),
	@Location varchar(50)
AS
BEGIN
	
	
	SET NOCOUNT ON;

    SELECT TrackingEntity.Barcode, MasterItem.Description, Qty
	FROM TrackingEntity INNER JOIN
	[Location] ON TrackingEntity.Location_id = [Location].ID INNER JOIN
	MasterItem ON TrackingEntity.MasterItem_id = MasterItem.ID INNER JOIN
	(
		SELECT Item_id
		FROM Document INNER JOIN
		DocumentDetail ON Document.ID = DocumentDetail.Document_id
		WHERE Document.Number = @Document AND ISNULL(DocumentDetail.ActionQty, 0) < DocumentDetail.Qty
		GROUP BY Item_id
	) document ON MasterItem.ID = document.Item_id
	WHERE [Location].Barcode = @Location AND TrackingEntity.InStock = 1 AND TrackingEntity.Qty > 0
END
