CREATE PROCEDURE [dbo].[PrescriptStockTakeCountTrackingEntity] (
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
	DECLARE @CarryingEntity_Barcode varchar (30)
	DECLARE @CarryingEntity_id bigint
	DECLARE @StockTakeSession_Name varchar (30)
	DECLARE @StockTakeSession_id bigint
	DECLARE @Count varchar (5)
	DECLARE @CountQty decimal (19,4)

	SELECT @StockTakeSession_Name = [Value] FROM @input WHERE [Name] = 'Session'
	SELECT @StockTakeSession_id = ID FROM StockTakeSession WHERE [Name] = @StockTakeSession_Name AND Active = 1
	SELECT @Count = [Value] FROM @input WHERE [Name] = 'Count'

	IF EXISTS (SELECT ID FROM TrackingEntity WHERE Barcode = @stepInput)
	BEGIN
	
		SELECT @TrackingEntity_Barcode = @stepInput
		SELECT @TrackingEntity_id = ID FROM TrackingEntity WHERE Barcode = @TrackingEntity_Barcode

		IF EXISTS (SELECT ID FROM StockTakeLines WHERE TrackingEntity_id = @TrackingEntity_id AND [Status] <> 'OUTSTANDING' AND StockTakeSession_id = @StockTakeSession_id)
		BEGIN
			SELECT @CountQty = CASE @Count
				WHEN '1' THEN ISNULL(Count1Qty, 0)
				WHEN '2' THEN ISNULL(Count2Qty, 0)
				ELSE ISNULL(Count3Qty, 0)
			END
			FROM StockTakeLines 
			WHERE TrackingEntity_id = @TrackingEntity_id AND StockTakeSession_id = @StockTakeSession_id

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
			SELECT @valid = 0
			SELECT @message = CONCAT('Cannot find information on barcode ', @TrackingEntity_Barcode, ' in stock take session')
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

		SELECT @CountQty =	CASE @Count
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
