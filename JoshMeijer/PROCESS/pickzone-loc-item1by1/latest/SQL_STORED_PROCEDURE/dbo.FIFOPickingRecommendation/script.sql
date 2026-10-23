CREATE Procedure [dbo].[FIFOPickingRecommendation]
	@Document varchar(30), @LPReset bit = 1
AS
BEGIN
	DECLARE @DocumentID bigint
		SELECT @DocumentID = ID FROM Document WHERE Number = @Document
	
	IF (ISNULL(@DocumentID, 0) = 0)
		RETURN;
	DECLARE @FifoPickRecommendation TABLE (
		DocumentDetailID bigint,
		LinePriority int,
		MasterItemID bigint,
		QtyOrdered decimal(19,4),
		ActionQty decimal(19,4),
		Instruction varchar(250),
		TrackingEntityId bigint,
		TrackingEntityCode varchar(30),
		TrackingEntityQty decimal(19,4),
		LocationId bigint,
		LocationName varchar(100),
		LocationCategory varchar(100),
		FromLocation varchar(50)
	)
	INSERT INTO @FifoPickRecommendation (DocumentDetailID, MasterItemID, QtyOrdered, ActionQty, FromLocation)
	SELECT ID, Item_id, Qty, ActionQty, FromLocation FROM DocumentDetail WHERE Document_id = @DocumentID
	UPDATE @FifoPickRecommendation
	SET TrackingEntityId = ID,
		TrackingEntityCode = TrackingEntityBarcode,
		TrackingEntityQty = Qty,
		LocationId = Location_id,
		LocationName = RecommendedTable.LocationName,
		LocationCategory = RecommendedTable.LocationCategory
	FROM (
		SELECT ROW_NUMBER() OVER (PARTITION BY MasterItem_id ORDER BY CreatedDate) RowNum,
			TrackingEntity.ID,
			TrackingEntity.Barcode TrackingEntityBarcode,
			Qty,
			Location_id,
			MasterItem_id,
			Location.Name LocationName,
			Location.Category LocationCategory,
			Location.ERPLocation
		FROM TrackingEntity WITH (NOLOCK)
		INNER JOIN Location WITH (NOLOCK) ON TrackingEntity.Location_id = Location.ID
		WHERE Qty <> 0 AND InStock = 1 AND OnHold <> 1 AND ISNULL(ExpiryDate, (GETDATE() + 1)) > GETDATE() 
		AND MasterItem_id IN (SELECT MasterItemID FROM @FifoPickRecommendation) AND Location.NonStock = 0 
		AND Location.Type NOT IN ('RECEIVING','LOST','CART')
	) AS RecommendedTable
	WHERE MasterItemID = MasterItem_id AND ERPLocation = FromLocation
	UPDATE @FifoPickRecommendation
	SET TrackingEntityId = ID,
		TrackingEntityCode = TrackingEntityBarcode,
		TrackingEntityQty = Qty,
		LocationId = Location_id,
		LocationName = RecommendedTable.LocationName
	FROM (
		SELECT ROW_NUMBER() OVER (PARTITION BY MasterItem_id ORDER BY CreatedDate) RowNum,
			TrackingEntity.ID,
			TrackingEntity.Barcode TrackingEntityBarcode,
			Qty,
			Location_id,
			MasterItem_id,
			Location.Name LocationName,
			Location.Category LocationCategory,
			Location.ERPLocation
		FROM TrackingEntity WITH (NOLOCK)
		INNER JOIN Location WITH (NOLOCK) ON TrackingEntity.Location_id = Location.ID
		WHERE Qty <> 0 AND InStock = 1 AND OnHold <> 1 AND ISNULL(ExpiryDate, (GETDATE() + 1)) > GETDATE() 
		AND MasterItem_id IN (SELECT MasterItemID FROM @FifoPickRecommendation) 
		AND Location.NonStock = 0
		AND Location.Type NOT IN ('LOST','CART')
	) AS RecommendedTable
	WHERE MasterItemID = MasterItem_id AND TrackingEntityId IS NULL AND ERPLocation = FromLocation
	UPDATE @FifoPickRecommendation
	SET Instruction = InstructionMessage
	FROM (
		SELECT DocumentDetailID AS DocDetailID,
			CASE WHEN (TrackingEntityId IS NULL) THEN 'NO STOCK' WHEN (LocationName = 'Receiving') THEN 'MOVE STOCK FROM RECEIVING' ELSE CONCAT('ZONE ',LocationCategory,'|','Location: ', LocationName) END AS InstructionMessage
		FROM @FifoPickRecommendation
	) AS InstructionMessages
	WHERE DocumentDetailID = DocDetailID;
	With Ordered AS
	(
	SELECT DocumentDetailID, 
	ROW_NUMBER() OVER (ORDER BY LocationName) as NewPriority
	FROM @FifoPickRecommendation
	)
	UPDATE t
	SET LinePriority = o.NewPriority
	FROM @FifoPickRecommendation t
	JOIN Ordered o ON T.DocumentDetailID = o.DocumentDetailID
	IF @LPReset = 1
		UPDATE DocumentDetail
		SET Instruction = FIFOTable.Instruction,
			LinePriority = FIFOTable.LinePriority
		FROM @FifoPickRecommendation FIFOTable
		WHERE DocumentDetailID = ID AND DocumentDetail.Completed = 0 
	ELSE
		UPDATE DocumentDetail
		SET Instruction = FIFOTable.Instruction,
			LinePriority = FIFOTable.LinePriority
		FROM @FifoPickRecommendation FIFOTable
		WHERE DocumentDetailID = ID AND DocumentDetail.Completed = 0 
		and Documentdetail.LinePriority <> 99000
END