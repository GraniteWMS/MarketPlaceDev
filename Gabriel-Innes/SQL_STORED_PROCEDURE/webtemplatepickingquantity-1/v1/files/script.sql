CREATE PROCEDURE [dbo].[WebtemplatePickingQuantity]
	@TrackingEntity varchar(30),
	@Document varchar(50)
	
AS
BEGIN
SELECT DISTINCT Barcode, 
       Code AS MasterItemCode, 
	   MasterItem.Description, 
	   TrackingEntity.Qty AS QtyOnBarcode,
	   (DocumentDetail.Qty - ActionQty) AS QtyToPick
FROM TrackingEntity WITH (NOLOCK)LEFT JOIN 
	 MasterItem WITH (NOLOCK) ON MasterItem.ID = TrackingEntity.MasterItem_id LEFT JOIN 
	 DocumentDetail WITH (NOLOCK) ON TrackingEntity.MasterItem_id = DocumentDetail.Item_id LEFT JOIN 
	 Document WITH (NOLOCK)ON DocumentDetail.Document_id = Document.ID
WHERE TrackingEntity.Barcode = @TrackingEntity AND
      Document.Number = @Document
END
