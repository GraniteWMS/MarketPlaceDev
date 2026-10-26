CREATE VIEW [dbo].[ERP_StockOnHand]
AS
SELECT 'Mstr' AS LOCATION, [Cranbrook Flavours].dbo.StkItem.Code AS ITEMNO, [Cranbrook Flavours].dbo._etblStockQtys.QtyOnHand AS QTYONHAND, [Cranbrook Flavours].dbo._etblStockQtys.QtyOnSO AS QTYSALORDR, 
                  [Cranbrook Flavours].dbo._etblStockQtys.QtyOnPO AS QTYONORDER, [Cranbrook Flavours].dbo._etblStockCosts.AverageCost AS AVRCOST
FROM     [Cranbrook Flavours].dbo.StkItem INNER JOIN
                  [Cranbrook Flavours].dbo._etblStockQtys ON [Cranbrook Flavours].dbo.StkItem.StockLink = [Cranbrook Flavours].dbo._etblStockQtys.StockID INNER JOIN
				  [Cranbrook Flavours].dbo._etblStockCosts ON [Cranbrook Flavours].dbo.StkItem.StockLink = [Cranbrook Flavours].dbo._etblStockCosts.StockID
