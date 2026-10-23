CREATE VIEW [dbo].[WebtemplatePickingTrackingEntity]
AS
	SELECT Number as DocumentNumber,
		   MasterItem.Code,
		   MasterItem.Description,
		   DocumentDetail.Qty,
		   DocumentDetail.ActionQty,
		   (DocumentDetail.Qty - ActionQty) AS QtyToPick,
		   CASE WHEN (Instruction = 'NO STOCK AVAILABLE')
		   THEN DocumentDetail.Instruction
		   ELSE LEFT(Instruction, CHARINDEX('TE:', Instruction) - 1)
		   END AS Instruction,
		   CASE WHEN (Instruction = 'NO STOCK AVAILABLE')
		   THEN 'NO STOCK'
		   ELSE RIGHT(DocumentDetail.Instruction, 10) 
		   END as Barcode
	FROM 
	Document LEFT JOIN 
	DocumentDetail ON Document.ID = DocumentDetail.Document_id LEFT JOIN 
	MasterItem ON DocumentDetail.Item_id = MasterItem.ID INNER JOIN
	TrackingEntity ON TrackingEntity.MasterItem_id = MasterItem.ID
	WHERE Document.Type = 'ORDER' AND
		  DocumentDetail.Completed <> 1 AND 
		  DocumentDetail.Cancelled <> 1
	
