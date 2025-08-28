CREATE VIEW Base_Inventory_Summary AS 
CREATE VIEW [dbo].[Base_Inventory_Summary]
AS
SELECT     dbo.MasterItem.ID, dbo.MasterItem.Code, dbo.MasterItem.Description AS Item, SUM(TSQL.Qty) AS QtyOnHand, TSQL.Site, TSQL.ERPLocation, dbo.MasterItem.Category, dbo.MasterItem.Type
FROM         dbo.MasterItem RIGHT OUTER JOIN
                          (SELECT     MasterItem_1.ID AS MasterID, dbo.TrackingEntity.Qty, MasterItem_1.Code, dbo.Location.Name AS Location, dbo.Location.Site, 
                                                   dbo.Location.ERPLocation
                            FROM          dbo.TrackingEntity LEFT OUTER JOIN
                                                   dbo.Location ON dbo.TrackingEntity.Location_id = dbo.Location.ID LEFT OUTER JOIN
                                                   dbo.MasterItem AS MasterItem_1 ON dbo.TrackingEntity.MasterItem_id = MasterItem_1.ID 
                            WHERE      (dbo.TrackingEntity.InStock = 1) and (dbo.Location.NonStock = 0)
                            GROUP BY MasterItem_1.ID, MasterItem_1.Code,  dbo.TrackingEntity.Qty, dbo.TrackingEntity.Barcode, dbo.Location.Name, dbo.Location.Site, 
                                                   dbo.Location.ERPLocation) AS TSQL ON dbo.MasterItem.ID = TSQL.MasterID
GROUP BY dbo.MasterItem.ID, dbo.MasterItem.Code, dbo.MasterItem.Description, TSQL.Site, TSQL.ERPLocation, dbo.MasterItem.Category, dbo.MasterItem.Type
