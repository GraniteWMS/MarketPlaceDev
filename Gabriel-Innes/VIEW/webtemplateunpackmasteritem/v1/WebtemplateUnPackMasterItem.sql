CREATE VIEW [dbo].[WebtemplateUnPackMasterItem]
AS
	SELECT MasterItem.Code AS MasterItem, ActionQty AS PackedQty, Barcode
	FROM [Transaction] LEFT JOIN 
		 MasterItem ON [Transaction].FromMasterItem_id = MasterItem.ID LEFT JOIN
		 CarryingEntity ON [Transaction].ContainableEntity_id = CarryingEntity.ID
	WHERE IntegrationStatus = 0 AND
		  [Transaction].Type = 'Pack' AND 
		  [Transaction].ReversalTransaction_id IN (NULL, 0)
