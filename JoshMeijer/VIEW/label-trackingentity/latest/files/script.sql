CREATE VIEW [dbo].[Label_TrackingEntity]
AS
SELECT          dbo.TrackingEntity.Barcode, dbo.MasterItem.Code, dbo.MasterItem.Description, 
                dbo.TrackingEntity.Qty, dbo.TrackingEntity.SerialNumber, 
                dbo.TrackingEntity.Batch, dbo.TrackingEntity.ExpiryDate, 
                dbo.MasterItem.Category, dbo.MasterItem.Type, dbo.MasterItem.UOM,
                [dbo].[GenerateJulianDateCode] (CreatedDate) as JDay,
                dbo.TrackingEntity.CreatedDate as ReceivedDate
FROM            dbo.MasterItem 
INNER JOIN dbo.TrackingEntity ON dbo.MasterItem.ID = dbo.TrackingEntity.MasterItem_id
