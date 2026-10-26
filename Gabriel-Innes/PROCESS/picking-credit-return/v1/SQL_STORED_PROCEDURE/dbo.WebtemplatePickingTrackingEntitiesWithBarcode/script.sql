CREATE PROCEDURE [dbo].[WebtemplatePickingTrackingEntitiesWithBarcode]
	@Document varchar(50),
	@Cage varchar(50)
AS
BEGIN 
		IF (@Document LIKE 'AU%')
		BEGIN
			SELECT DISTINCT MasterItem.Code,
					MasterItem.Description,
					(Qty - ActionQty) AS QtyToPick,
					Instruction,
					RIGHT(Instruction, 9) AS TrackingEntity
			FROM 
			Document WITH (NOLOCK) LEFT JOIN 
			DocumentDetail WITH (NOLOCK) ON Document.ID = DocumentDetail.Document_id LEFT JOIN 
			MasterItem WITH (NOLOCK) ON DocumentDetail.Item_id = MasterItem.ID
			WHERE Document.Type = 'ORDER' AND
				  DocumentDetail.Completed <> 1 AND 
				  DocumentDetail.Cancelled <> 1 AND 
				  Document.Number = CONCAT(@Document, '-', @Cage)
		END
	ELSE
		BEGIN 
			SELECT DISTINCT MasterItem.Code,
					MasterItem.Description,
					(Qty - ActionQty) AS QtyToPick,
					Instruction,
					RIGHT(Instruction, 9) AS TrackingEntity
			FROM 
			Document WITH (NOLOCK) LEFT JOIN 
			DocumentDetail WITH (NOLOCK) ON Document.ID = DocumentDetail.Document_id LEFT JOIN 
			MasterItem WITH (NOLOCK) ON DocumentDetail.Item_id = MasterItem.ID
			WHERE Document.Type = 'ORDER' AND
					DocumentDetail.Completed <> 1 AND 
					DocumentDetail.Cancelled <> 1 AND 
					Document.Number = @Document AND
					DocumentDetail.Comment = @Cage
		END
END
