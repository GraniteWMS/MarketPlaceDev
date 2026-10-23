CREATE Procedure [dbo].[FIFOPickingReturns]
	@DocumentID bigint,
	@ERPLocation varchar(30)
AS
BEGIN
		DECLARE @FifoPickRecomendation TABLE (
		DocumentDetailID bigint,
		LinePriority int,
		MasterItemID bigint,	
		QtyOrdered decimal(19,4),
		ActionQty decimal (19,4),
		Cage varchar(30),
		Instruction varchar(250),
		TrackingEntityId bigint,
		TrackingEntityCode varchar(30),
		TrackingEntityQty decimal(19,4),
		LocationId bigint,
		LocationName varchar(100)
		)
		INSERT INTO @FifoPickRecomendation(DocumentDetailID, MasterItemID, QtyOrdered, ActionQty)
		SELECT ID, Item_id, Qty, ActionQty FROM DocumentDetail WHERE Document_id = @DocumentID
		UPDATE @FifoPickRecomendation
		SET TrackingEntityId = ID, 
			TrackingEntityCode = TrackingEntityBarcode,
			TrackingEntityQty = Qty,
			LocationId = Location_id,
			LocationName = RecommendedTable.LocationName,
			Cage = RecommendedTable.Category
		FROM (SELECT ROW_NUMBER() OVER(PARTITION BY MasterItem_id ORDER BY CreatedDate  ) RowNum, 
					 TrackingEntity.ID, 
					 TrackingEntity.Barcode TrackingEntityBarcode, 
					 Qty,
					 Location_id, MasterItem_id, 
					 Location.Name LocationName,
					 Location.Category
			  FROM  TrackingEntity WITH (NOLOCK)LEFT JOIN 
					Location WITH (NOLOCK) ON TrackingEntity.Location_id = Location.ID
			  WHERE Qty <> 0 AND                                                                       
					InStock = 1 AND
		   			OnHold <> 1 AND
					ISNULL(ExpiryDate, (GETDATE() + 1)) > GETDATE() AND
					MasterItem_id IN (SELECT MasterItemID FROM @FifoPickRecomendation) AND
					Location.NonStock = 0 AND
					Location.ERPLocation = ISNULL(@ERPLocation, '') AND 
					Location.Barcode = 'RETURN'
					) AS RecommendedTable
		WHERE MasterItemID = MasterItem_id 
		UPDATE @FifoPickRecomendation
		SET Instruction = InstructionMessage 
		FROM 
		(SELECT DocumentDetailID AS DocDetailID,
				CASE WHEN (TrackingEntityId IS NULL)
							   THEN 'NO STOCK AVAILABLE'
							   ELSE CONCAT('Location: ', LocationName, ' TE: ', TrackingEntityCode ) 
							   END AS InstructionMessage
		FROM @FifoPickRecomendation) AS InstructionMessages
		WHERE DocumentDetailID = DocDetailID
		UPDATE @FifoPickRecomendation
		SET Cage = 'NO STOCK'
		WHERE Cage IS NULL
		UPDATE DocumentDetail
		SET Instruction = FIFOTable.Instruction,
			LinePriority = FIFOTable.LinePriority,
			Comment = Cage
		FROM @FifoPickRecomendation FIFOTable
		WHERE DocumentDetailID = ID  AND DocumentDetail.Completed = 0
END
