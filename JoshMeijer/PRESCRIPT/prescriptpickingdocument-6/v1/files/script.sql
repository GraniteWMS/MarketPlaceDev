CREATE PROCEDURE [dbo].[PrescriptPickingDocument] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
	SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @DocumentNumber varchar(30)
	SELECT @DocumentNumber = @stepInput
DECLARE @DocumentId bigint 
	SELECT @DocumentId = ID FROM Document WHERE Number = @DocumentNumber
DECLARE @TradingPartnerCode varchar(30)
	SELECT @TradingPartnerCode = TradingPartnerCode FROM Document WHERE Number = @DocumentNumber
DECLARE @ERPLocation varchar(30) = (SELECT ERPLocation FROM Document WHERE Number = @DocumentNumber)
IF NOT EXISTS(SELECT ID FROM Document WHERE Number = @DocumentNumber AND Status in ('RELEASED', 'ENTERED') AND Type = 'ORDER')
BEGIN
	SELECT @valid = 0                  
	SELECT @message = 'Document ' + @DocumentNumber + ' does not exist.'  
END
ELSE
BEGIN
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
		FROM (SELECT ROW_NUMBER() OVER(PARTITION BY MasterItem_id ORDER BY CreatedDate  ) RowNum, 
					 TrackingEntity.ID, 
					 TrackingEntity.Barcode TrackingEntityBarcode, 
					 Qty,
					 Location_id, MasterItem_id, 
					 Location.Name LocationName,
					 Location.Category
			  FROM  TrackingEntity  LEFT JOIN 
					Location ON TrackingEntity.Location_id = Location.ID
			  WHERE Qty <> 0 AND                                                                       
					InStock = 1 AND
		   			OnHold <> 1 AND
					ISNULL(ExpiryDate, (GETDATE() + 1)) > GETDATE() AND
					MasterItem_id IN (SELECT MasterItemID FROM @FifoPickRecomendation) AND
					Location.NonStock = 0 AND
					Location.ERPLocation = ISNULL(@ERPLocation, '') 
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
		UPDATE DocumentDetail
		SET Instruction = FIFOTable.Instruction,
			LinePriority = FIFOTable.LinePriority
		FROM @FifoPickRecomendation FIFOTable
		WHERE DocumentDetailID = ID 
	SELECT @valid = 1                  
	SELECT @message = ''  
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
