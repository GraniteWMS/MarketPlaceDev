CREATE VIEW [dbo].[Report_App_Transactions]
AS
SELECT        TOP (100) PERCENT dbo.TrackingEntity.Barcode, dbo.MasterItem.Code, dbo.MasterItem.Description, dbo.[Transaction].Date, dbo.TrackingEntity.Batch, dbo.TrackingEntity.SerialNumber, dbo.TrackingEntity.ExpiryDate, 
                         dbo.[Transaction].FromQty, dbo.[Transaction].ToQty, dbo.[Transaction].ActionQty, dbo.Users.Name AS [User], dbo.[Transaction].DocumentReference, dbo.[Document].Number AS DocumentNumber, 
                         dbo.[Transaction].IntegrationStatus, dbo.CarryingEntity.Barcode AS Pallet, dbo.[Transaction].Comment, L1.Name AS FromLocation, L2.Name AS ToLocation, L3.Site, dbo.[Transaction].Type AS TransactionType, 
                         dbo.[Transaction].IntegrationReference, dbo.[Transaction].Process,  L1.ERPLocation AS [FromLocationERP], L2.ERPLocation AS [ToLocationERP]
FROM            dbo.[Transaction] LEFT OUTER JOIN
                         dbo.TrackingEntity ON dbo.TrackingEntity.ID = dbo.[Transaction].TrackingEntity_id LEFT OUTER JOIN
                         dbo.MasterItem ON dbo.MasterItem.ID = dbo.TrackingEntity.MasterItem_id LEFT OUTER JOIN
                         dbo.CarryingEntity ON dbo.[Transaction].ContainableEntity_id = dbo.CarryingEntity.ID LEFT OUTER JOIN
                         dbo.Location AS L1 ON dbo.[Transaction].FromLocation_id = L1.ID LEFT OUTER JOIN
                         dbo.Location AS L2 ON dbo.[Transaction].ToLocation_id = L2.ID LEFT OUTER JOIN
                         dbo.Location AS L3 ON dbo.TrackingEntity.Location_id = L3.ID LEFT OUTER JOIN
                         dbo.Users ON dbo.[Transaction].User_id = dbo.Users.ID LEFT OUTER JOIN
                         dbo.[Document] ON dbo.[Document].ID = dbo.[Transaction].Document_id
WHERE        (dbo.[Transaction].Date >= GETDATE() - 750)
