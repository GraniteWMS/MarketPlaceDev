CREATE Procedure [dbo].[FIFOPickingRecommendation]
	@Document varchar(30)
AS
BEGIN
	DECLARE @DocumentID bigint
		SELECT @DocumentID = ID FROM Document WHERE Number = @Document
	DECLARE @ERPLocation varchar(30)
		SELECT @ERPLocation = ERPLocation FROM Document WHERE ID = @DocumentID
	
	IF (ISNULL(@DocumentID, 0) = 0) 
		RETURN;
		DECLARE @FifoPickRecomendation TABLE (
		DocumentDetailID bigint,
		LinePriority int,
		MasterItemID bigint,	
		QtyOrdered decimal(19,4),
		ActionQty decimal (19,4),
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
			LocationName = RecommendedTable.LocationName
		FROM (SELECT ROW_NUMBER() OVER(PARTITION BY MasterItem_id ORDER BY CreatedDate) RowNum, 
					 TrackingEntity.ID, 
					 TrackingEntity.Barcode TrackingEntityBarcode, 
					 Qty,
					 Location_id, MasterItem_id, 
					 Location.Name LocationName,
					 Location.Category
			  FROM  TrackingEntity  WITH (NOLOCK )INNER JOIN 
					Location WITH (NOLOCK ) ON TrackingEntity.Location_id = Location.ID
			  WHERE Qty <> 0 AND                                                                       
					InStock = 1 AND
		   			OnHold <> 1 AND
					ISNULL(ExpiryDate, (GETDATE() + 1)) > GETDATE() AND
					MasterItem_id IN (SELECT MasterItemID FROM @FifoPickRecomendation) AND
					Location.NonStock = 0 AND
					Location.ERPLocation = ISNULL(@ERPLocation, '') AND 
					
					Location.[Type] NOT IN ('DAMAGES','STAGING')
					) AS RecommendedTable
		WHERE MasterItemID = MasterItem_id 
		
		UPDATE @FifoPickRecomendation
		SET TrackingEntityId = ID, 
			TrackingEntityCode = TrackingEntityBarcode,
			TrackingEntityQty = Qty,
			LocationId = Location_id,
			LocationName = RecommendedTable.LocationName
		FROM (SELECT ROW_NUMBER() OVER(PARTITION BY MasterItem_id ORDER BY CreatedDate) RowNum, 
					 TrackingEntity.ID, 
					 TrackingEntity.Barcode TrackingEntityBarcode, 
					 Qty,
					 Location_id, MasterItem_id, 
					 Location.Name LocationName,
					 Location.Category
			  FROM  TrackingEntity  WITH (NOLOCK )INNER JOIN 
					Location WITH (NOLOCK ) ON TrackingEntity.Location_id = Location.ID
			  WHERE Qty <> 0 AND                                                                       
					InStock = 1 AND
		   			OnHold <> 1 AND
					ISNULL(ExpiryDate, (GETDATE() + 1)) > GETDATE() AND
					MasterItem_id IN (SELECT MasterItemID FROM @FifoPickRecomendation) AND
					Location.NonStock = 0 AND
					Location.ERPLocation = ISNULL(@ERPLocation, '') 
					) AS RecommendedTable
		WHERE MasterItemID = MasterItem_id AND TrackingEntityId IS NULL
		UPDATE @FifoPickRecomendation
		SET Instruction = InstructionMessage 
		FROM 
		(SELECT DocumentDetailID AS DocDetailID,
				CASE WHEN (TrackingEntityId IS NULL)
							   THEN 'NO STOCK AVAILABLE'
					 WHEN (LocationName = 'Receiving')
							   THEN 'MOVE STOCK FROM RECEIVING'
					ELSE CONCAT('Location: ', LocationName)  
							   END AS InstructionMessage
		FROM @FifoPickRecomendation) AS InstructionMessages
		WHERE DocumentDetailID = DocDetailID
		UPDATE DocumentDetail
		SET Instruction = FIFOTable.Instruction,
			LinePriority = FIFOTable.LinePriority
		FROM @FifoPickRecomendation FIFOTable
		WHERE DocumentDetailID = ID AND DocumentDetail.Completed = 0
END
