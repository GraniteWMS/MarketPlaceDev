CREATE VIEW WebTemplate_AllocateBarcodeToWorkOrder_TrackingEntity
AS
SELECT ID, Batch, Barcode, AllocatedQty, CONCAT(ItemCode, ' | ', ItemDescription) AS SKU, [User] FROM Custom_VW_AllocatedBarcodes
