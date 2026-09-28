CREATE VIEW [dbo].[WebtemplatePickingQty]
AS
SELECT Barcode, 
       Code AS MasterItemCode, 
	   MasterItem.Description, 
	   TrackingEntity.Qty AS QtyOnBarcode,
	   (DocumentDetail.Qty - ActionQty) AS QtyToPick,
	   Number AS Document
FROM TrackingEntity LEFT JOIN 
	 MasterItem ON MasterItem.ID = TrackingEntity.MasterItem_id LEFT JOIN 
	 DocumentDetail ON TrackingEntity.MasterItem_id = DocumentDetail.Item_id LEFT JOIN 
	 Document ON DocumentDetail.Document_id = Document.ID
