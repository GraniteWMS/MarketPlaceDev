

CREATE VIEW [dbo].[Custom_ERP_StockQtyReserved] 
AS

SELECT CAST(StockID as varchar) MasterItem_ERPIdentification,
		QtyOnHand,
		QtyReserved QtyReserved,
		WhseMst.Code 'Location'
FROM [EvolutionDatabase].dbo.[_etblStockQtys] WITH (NOLOCK) INNER JOIN
[EvolutionDatabase].dbo.WhseMst ON [_etblStockQtys].WhseID = WhseMst.WhseLink

