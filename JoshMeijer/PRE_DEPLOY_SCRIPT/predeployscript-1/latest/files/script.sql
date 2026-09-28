CREATE VIEW [dbo].[Custom_Integration_Evolution_SalesOrderDetailReserved] 
AS

SELECT	CAST([_btblInvoiceLines].iInvoiceID as varchar) Document_ERPIdentification, 
		CAST([_btblInvoiceLines].idInvoiceLines as varchar) LineNumber, 
		CAST([_btblInvoiceLines].idInvoiceLines as varchar) ERPIdentification,  
		fQtyReserved QtyReserved,
		WhseMst.Code FromLocation, 
		CAST(iStockCodeID as varchar) MasterItem_ERPIdentification, 
		CAST([_btblInvoiceLines].iOrigLineID as varchar) iOrigLineID, 
		[_btblInvoiceLineDetails].cLotNumber Batch
FROM [EvolutionDatabase].dbo.[_btblInvoiceLines] WITH (NOLOCK) LEFT JOIN 
[EvolutionDatabase].dbo.WhseMst ON [_btblInvoiceLines].iWarehouseID = WhseMst.WhseLink INNER JOIN
[EvolutionDatabase].dbo.InvNum ON [_btblInvoiceLines].iInvoiceID = InvNum.AutoIndex INNER JOIN
[EvolutionDatabase].dbo.StkItem ON [_btblInvoiceLines].iStockCodeID = StkItem.StockLink LEFT JOIN 
[EvolutionDatabase].dbo.[_btblInvoiceLineDetails] ON [_btblInvoiceLines].idInvoiceLines = [_btblInvoiceLineDetails].idInvoiceLineDetails
WHERE InvNum.DocType = 4 AND StkItem.WhseItem = 1 
GO

CREATE VIEW [dbo].[Custom_ERP_StockQtyReserved] 
AS

SELECT CAST(StockID as varchar) MasterItem_ERPIdentification,
		QtyOnHand,
		QtyReserved QtyReserved,
		WhseMst.Code 'Location'
FROM [EvolutionDatabase].dbo.[_etblStockQtys] WITH (NOLOCK) INNER JOIN
[EvolutionDatabase].dbo.WhseMst ON [_etblStockQtys].WhseID = WhseMst.WhseLink

GO