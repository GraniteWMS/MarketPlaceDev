CREATE PROCEDURE [dbo].[Prescript_StockTakeCount_TrackingEntity] (
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
DECLARE @TrackingEntity_Barcode varchar (30)
DECLARE @TrackingEntity_id bigint
DECLARE @TrackingEntityQty decimal(19, 4)
DECLARE @CarryingEntity_Barcode varchar (30)
DECLARE @CarryingEntity_id bigint
DECLARE @StockTakeSession_Name varchar (30)
DECLARE @StockTakeSession_id bigint
DECLARE @MasterItem_id bigint
DECLARE @MasterItem_Code varchar(50)
DECLARE @Location_id bigint
DECLARE @Location_erp varchar(50)
DECLARE @Count varchar (5)
DECLARE @CountQty decimal (19,4)
SELECT @StockTakeSession_Name = [Value] FROM @input WHERE [Name] = 'Session'
SELECT @StockTakeSession_id = ID FROM StockTakeSession WHERE [Name] = @StockTakeSession_Name AND Active = 1
SELECT @Count = [Value] FROM @input WHERE [Name] = 'Count'
IF EXISTS (SELECT ID FROM TrackingEntity WHERE Barcode = @stepInput)
BEGIN
	
	SELECT @TrackingEntity_Barcode = @stepInput
	SELECT @TrackingEntity_id = ID, @TrackingEntityQty = Qty FROM TrackingEntity WHERE Barcode = @TrackingEntity_Barcode
	INSERT INTO @Output
	SELECT 'Qty', @TrackingEntityQty
	IF EXISTS (SELECT ID FROM StockTakeLines WHERE TrackingEntity_id = @TrackingEntity_id AND [Status] <> 'OUTSTANDING' AND StockTakeSession_id = @StockTakeSession_id)
	BEGIN
		SELECT @CountQty = CASE @Count
							WHEN '1' THEN ISNULL(Count1Qty, 0)
							WHEN '2' THEN ISNULL(Count2Qty, 0)
							ELSE ISNULL(Count3Qty, 0)
						   END
						   FROM StockTakeLines WHERE TrackingEntity_id = @TrackingEntity_id AND StockTakeSession_id = @StockTakeSession_id
		IF @CountQty > 0
		BEGIN
			SELECT @valid = 0
			SELECT @message = CONCAT(@TrackingEntity_Barcode, ' has already been scanned on count ', @Count)
		END
		ELSE
		BEGIN
			SELECT @valid = 1
			SELECT @message = ''
		END
	END
	ELSE IF EXISTS (SELECT ID FROM StockTakeLines WHERE TrackingEntity_id = @TrackingEntity_id AND [Status] = 'OUTSTANDING' AND StockTakeSession_id = @StockTakeSession_id)
	BEGIN
		SELECT @valid = 1
		SELECT @message = ''
	END
	ELSE 
	
	
	
	
	BEGIN
			SELECT @TrackingEntityQty = Qty FROM TrackingEntity WHERE ID = @TrackingEntity_id
			SELECT @MasterItem_id = MasterItem_id FROM TrackingEntity WHERE ID = @TrackingEntity_id
			SELECT @MasterItem_Code = Code FROM MasterItem WHERE ID = @MasterItem_id
			SELECT @Location_id = @Location_id FROM TrackingEntity WHERE ID = @TrackingEntity_id
			SELECT @Location_erp = ERPLocation FROM [Location] WHERE ID = @Location_id
			INSERT INTO StockTakeLines ([StockTakeSession_id], [Barcode], [MasterItemCode], [OpeningLocationERP], [OpeningLocation_id], [OpeningQty], [Status], [MasterItem_id], [TrackingEntity_id])
			SELECT @StockTakeSession_id, @TrackingEntity_Barcode, @MasterItem_Code, @Location_erp, @Location_id, @TrackingEntityQty, 'OUTSTANDING', @MasterItem_id, @TrackingEntity_id
			SELECT @valid = 1
			SELECT @message = CONCAT('Barcode ', @TrackingEntity_Barcode, ' added to session')
		END
END
ELSE IF EXISTS (SELECT ID FROM CarryingEntity WHERE Barcode = @stepInput)
BEGIN
	SELECT @CarryingEntity_Barcode = @stepInput
	SELECT @CarryingEntity_id = ID FROM CarryingEntity WHERE Barcode = @CarryingEntity_Barcode
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
		SELECT @valid = 0
		SELECT @message = CONCAT(@CarryingEntity_Barcode, ' contains a Tracking Entity that has already been scanned on count ', @Count)
	END
	ELSE
	BEGIN
		SELECT @valid = 1
		SELECT @message = ''
	END
END
ELSE 
BEGIN
	SELECT @valid = 1
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
