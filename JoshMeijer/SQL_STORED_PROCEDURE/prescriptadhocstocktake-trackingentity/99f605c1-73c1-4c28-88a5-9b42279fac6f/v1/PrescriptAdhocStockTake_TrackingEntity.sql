CREATE PROCEDURE [dbo].[PrescriptAdhocStockTake_TrackingEntity] (
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
DECLARE @StockTakeSession_Name varchar (20)
DECLARE @StockTakeSession_id bigint
DECLARE @Count varchar (5)
DECLARE @CountQty decimal (19,4)
DECLARE @CountColumnName varchar (20)
DECLARE @TrackingEntity_Barcode varchar (30)
DECLARE @TrackingEntity_id bigint
DECLARE @TrackingEntity_qty decimal (19,4)
DECLARE @MasterItem_id bigint
DECLARE @MasterItem_Code varchar (40)
DECLARE @Location_id bigint
DECLARE @Location_erp varchar (15)
DECLARE @InStock bit
DECLARE @CarryingEntity_Barcode varchar (30)
DECLARE @CarryingEntity_id bigint
SELECT @StockTakeSession_Name = [Value] FROM @input WHERE [Name] = 'Session'
SELECT @StockTakeSession_id = ID FROM StockTakeSession WHERE [Name] = @StockTakeSession_Name
SELECT @Count = [Value] FROM @input WHERE [Name] = 'Count'
IF EXISTS(SELECT ID FROM TrackingEntity WHERE Barcode = @stepInput)
BEGIN
	SELECT @TrackingEntity_Barcode = @stepInput
	SELECT @TrackingEntity_id = ID FROM TrackingEntity WHERE Barcode = @TrackingEntity_Barcode
	SELECT @InStock = InStock FROM TrackingEntity WHERE ID = @TrackingEntity_id
	SELECT @Location_id = Location_id FROM TrackingEntity WHERE ID = @TrackingEntity_id
	SELECT @Location_erp = ERPLocation FROM [Location] WHERE ID = @Location_id
	IF (SELECT InStock FROM TrackingEntity WHERE ID = @TrackingEntity_id) = 1
	BEGIN
		IF NOT EXISTS(SELECT ID FROM StockTakeLines WHERE StockTakeSession_id = @StockTakeSession_id AND TrackingEntity_id = @TrackingEntity_id)
		BEGIN
			SELECT @TrackingEntity_qty = Qty FROM TrackingEntity WHERE ID = @TrackingEntity_id
			SELECT @MasterItem_id = MasterItem_id FROM TrackingEntity WHERE ID = @TrackingEntity_id
			SELECT @MasterItem_Code = Code FROM MasterItem WHERE ID = @MasterItem_id
			SELECT @Location_id = @Location_id FROM TrackingEntity WHERE ID = @TrackingEntity_id
			SELECT @Location_erp = ERPLocation FROM [Location] WHERE ID = @Location_id
			INSERT INTO StockTakeLines ([StockTakeSession_id], [Barcode], [MasterItemCode], [OpeningLocationERP], [OpeningLocation_id], [OpeningQty], [Status], [MasterItem_id], [TrackingEntity_id])
			SELECT @StockTakeSession_id, @TrackingEntity_Barcode, @MasterItem_Code, @Location_erp, @Location_id, @TrackingEntity_qty, 'OUTSTANDING', @MasterItem_id, @TrackingEntity_id
			SELECT @valid = 1
			SELECT @message = CONCAT('Barcode ', @TrackingEntity_Barcode, ' added to session')
		END
		ELSE
		BEGIN
			SELECT @valid = 1
			SELECT @message = ''
			SELECT @CountQty = CASE @Count
					WHEN '1' THEN ISNULL(Count1Qty, 0)
					WHEN '2' THEN ISNULL(Count2Qty, 0)
					ELSE ISNULL(Count3Qty, 0)
					END
					FROM StockTakeLines WHERE TrackingEntity_id = @TrackingEntity_id AND StockTakeSession_id = @StockTakeSession_id
			IF @CountQty > 0
			BEGIN
				UPDATE StockTakeLines 
				SET Count1Qty = (CASE WHEN @Count = '1' THEN 0 ELSE Count1Qty END),
					Count2Qty = (CASE WHEN @Count = '2' THEN 0 ELSE Count2Qty END),
					Count3Qty = (CASE WHEN @Count = '3' THEN 0 ELSE Count3Qty END)
				WHERE StockTakeSession_id = @StockTakeSession_id AND TrackingEntity_id = @TrackingEntity_id
			END
		END
	END
	ELSE
	BEGIN
		SELECT @valid = 0
		SELECT @message = CONCAT('Barcode ', @TrackingEntity_Barcode, ' is not in stock')
	END
END
ELSE IF EXISTS(SELECT ID FROM CarryingEntity WHERE Barcode = @stepInput)
BEGIN
	SELECT @CarryingEntity_Barcode = @stepInput
	SELECT @CarryingEntity_id = ID FROM CarryingEntity WHERE Barcode = @CarryingEntity_Barcode
	IF EXISTS (SELECT ID FROM TrackingEntity WHERE BelongsToEntity_id = @CarryingEntity_id 
				AND ID NOT IN (SELECT TrackingEntity_id FROM StockTakeLines WHERE StockTakeSession_id = @StockTakeSession_id))
				AND @Count = 1
	BEGIN
		INSERT INTO StockTakeLines ([StockTakeSession_id], [Barcode], [MasterItemCode], [OpeningLocationERP], [OpeningLocation_id], [OpeningQty], [Status], [MasterItem_id], [TrackingEntity_id])
		SELECT @StockTakeSession_id, TE.Barcode, MI.Code, L.ERPLocation, L.ID, TE.Qty, 'OUTSTANDING', MI.ID, TE.ID
		FROM TrackingEntity TE INNER JOIN
		MasterItem MI ON TE.MasterItem_id = MI.ID INNER JOIN
		[Location] L ON TE.Location_id = L.ID
		WHERE TE.BelongsToEntity_id = @CarryingEntity_id
		AND TE.ID NOT IN (SELECT TrackingEntity_id FROM StockTakeLines WHERE StockTakeSession_id = @StockTakeSession_id)
		UPDATE StockTakeLines 
			SET Count1Qty = CASE WHEN @Count = '1' THEN 0 ELSE Count1Qty END,
				Count2Qty = CASE WHEN @Count = '2' THEN 0 ELSE Count2Qty END,
				Count3Qty = CASE WHEN @Count = '3' THEN 0 ELSE Count3Qty END
			WHERE StockTakeSession_id = @StockTakeSession_id AND TrackingEntity_id IN (SELECT ID FROM TrackingEntity WHERE BelongsToEntity_id = @CarryingEntity_id)
		SELECT @valid = 1
		SELECT @message = CONCAT('Pallet ', @CarryingEntity_Barcode, ' added to session')
	END
	ELSE 
	BEGIN
		SELECT @valid = 1
		SELECT @message = ''
		DECLARE @TrackingEntity_CountQuantities TABLE
		(
		TrackingEntity_id bigint,
		Count1Qty decimal (19,4),
		Count2Qty decimal (19,4),
		Count3Qty decimal (19,4)
		)
		INSERT INTO @TrackingEntity_CountQuantities (TrackingEntity_id, Count1Qty, Count2Qty, Count3Qty)
		SELECT STL.TrackingEntity_id, ISNULL(STL.Count1Qty, 0), ISNULL(STL.Count2Qty, 0), ISNULL(STL.Count3Qty, 0)
		FROM StockTakeLines STL INNER JOIN
		TrackingEntity TE ON STL.TrackingEntity_id = TE.ID
		WHERE TE.BelongsToEntity_id = @CarryingEntity_id AND STL.StockTakeSession_id = @StockTakeSession_id
		SELECT @CountQty = CASE @Count
							WHEN '1' THEN SUM(Count1Qty)
							WHEN '2' THEN SUM(Count2Qty)
							ELSE SUM(Count3Qty)
						   END
						   FROM @TrackingEntity_CountQuantities
		IF @CountQty > 0
		BEGIN
			UPDATE StockTakeLines 
			SET Count1Qty = CASE WHEN @Count = '1' THEN 0 ELSE Count1Qty END,
				Count2Qty = CASE WHEN @Count = '2' THEN 0 ELSE Count2Qty END,
				Count3Qty = CASE WHEN @Count = '3' THEN 0 ELSE Count3Qty END
			WHERE StockTakeSession_id = @StockTakeSession_id AND TrackingEntity_id IN (SELECT TrackingEntity_id FROM @TrackingEntity_CountQuantities)
		END
	END
END
ELSE 
BEGIN
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
