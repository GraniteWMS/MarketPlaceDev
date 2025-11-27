
CREATE VIEW [dbo].[Custom_API_QueryInventoryVariance]
AS
SELECT       ISNULL(dbo.MasterItem.ID, dbo.Base_Inventory_Summary.ID) AS MasterItem_id, ISNULL(dbo.MasterItem.Code, dbo.Base_Inventory_Summary.Code) AS MasterItemCode, ISNULL(dbo.MasterItem.Description, dbo.Base_Inventory_Summary.Item) 
                      AS Description, ISNULL(dbo.Base_Inventory_Summary.QtyOnHand, 0) AS WarehouseQty, ISNULL(dbo.[ERP_StockOnHand].QTYONHAND, 0) AS ERPQty, 
                      ISNULL(dbo.[ERP_StockOnHand].QTYONORDER, 0) AS PurchaseOrder, ISNULL(dbo.[ERP_StockOnHand].QTYSALORDR, 0) AS SalesOrder, 
                      ISNULL(dbo.Base_Inventory_Summary.QtyOnHand, 0) - ISNULL(dbo.[ERP_StockOnHand].QTYONHAND, 0) AS Discrepancy, 
                      ISNULL(dbo.Base_Inventory_Summary.QtyOnHand, 0) - CAST(dbo.[ERP_StockOnHand].QTYONHAND AS DECIMAL(18, 2)) 
                      - CAST(dbo.[ERP_StockOnHand].QTYSALORDR AS DECIMAL(18, 2)) AS SODiscrepancy, ((CASE WHEN CAST(ISNULL(dbo.Base_Inventory_Summary.QtyOnHand, 0) 
                      AS DECIMAL(18, 2)) = CAST(ISNULL(dbo.[ERP_StockOnHand].QTYONHAND, 0) AS DECIMAL(18, 2)) THEN 'GOOD' ELSE 'DISCREPANCY' END)) AS Status, 
                      CAST(((CASE WHEN ISNULL(dbo.[ERP_StockOnHand].QTYONHAND, 0) > ISNULL(Base_Inventory_Summary.QtyOnHand, 0) 
                      THEN (((dbo.Base_Inventory_Summary.QtyOnHand) / (CASE WHEN ISNULL((dbo.[ERP_StockOnHand].QTYONHAND), 0) 
                      = 0 THEN 1 ELSE ISNULL((dbo.[ERP_StockOnHand].QTYONHAND), 0) END)) * 100) WHEN ISNULL(dbo.[ERP_StockOnHand].QTYONHAND, 0) 
                      = ISNULL(Base_Inventory_Summary.QtyOnHand, 0) THEN 0 ELSE (((CASE WHEN ISNULL((dbo.[ERP_StockOnHand].QTYONHAND), 0) 
                      = 0 THEN 1 ELSE ISNULL((dbo.[ERP_StockOnHand].QTYONHAND), 0) END) / (CASE WHEN ISNULL((dbo.Base_Inventory_Summary.QtyOnHand), 0) 
                      = 0 THEN 1 ELSE (dbo.Base_Inventory_Summary.QtyOnHand) END)) * 100) END)) AS decimal(18, 2)) AS Percentage, dbo.Base_Inventory_Summary.Site, 
                      ISNULL(dbo.Base_Inventory_Summary.ERPLocation, dbo.[ERP_StockOnHand].LOCATION) AS ERPLocation, dbo.Base_Inventory_Summary.Category, dbo.Base_Inventory_Summary.Type
FROM         dbo.MasterItem LEFT OUTER JOIN
                      dbo.[ERP_StockOnHand] ON dbo.MasterItem.Code = dbo.[ERP_StockOnHand].ITEMNO COLLATE DATABASE_DEFAULT FULL OUTER JOIN
                      dbo.Base_Inventory_Summary ON dbo.MasterItem.Code = dbo.Base_Inventory_Summary.Code AND 
                      dbo.[ERP_StockOnHand].LOCATION COLLATE DATABASE_DEFAULT = dbo.Base_Inventory_Summary.ERPLocation
