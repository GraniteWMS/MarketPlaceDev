CREATE NONCLUSTERED INDEX [idxTE_OnHold_InStock_MasterItemID_Qty_Expiry]
ON [dbo].[TrackingEntity] ([OnHold],[InStock],[MasterItem_id],[Qty],[ExpiryDate])
INCLUDE ([Barcode],[SerialNumber],[CreatedDate],[Batch],[Location_id])
GO

CREATE NONCLUSTERED INDEX [idxDocumentDetail_Completed_Cancelled]
ON [dbo].[DocumentDetail] ([Document_id],[Completed],[Cancelled])
INCLUDE ([Item_id],[Qty],[ActionQty],[FromLocation])
GO