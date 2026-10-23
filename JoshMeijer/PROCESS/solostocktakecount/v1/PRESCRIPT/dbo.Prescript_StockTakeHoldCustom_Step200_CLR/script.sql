CREATE PROCEDURE [dbo].[Prescript_StockTakeHoldCustom_Step200_CLR] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),
  Value varchar(max)
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput'
	DECLARE @userID bigint
	DECLARE @Location varchar(30)
	DECLARE @Qty int
	DECLARE @CurrentLocation varchar(30)
	DECLARE @CurrentQty int
	DECLARE @AdjustmentType varchar(30)
	DECLARE @AdjustmentQty int
	DECLARE @Batch varchar(50)
	DECLARE @MasterItem varchar(50)
	DECLARE @CurrentMasterItem varchar(50)
	DECLARE @comment nvarchar(50)
	DECLARE @reference nvarchar(50)
	DECLARE @processName nvarchar(50)
	DECLARE @trackingEntityBarcode nvarchar(50)
	DECLARE @inventoryIdentifier nvarchar(50)
	DECLARE @locationIdentifier nvarchar(50)
	DECLARE @integrationReference nvarchar(50)
	DECLARE @masterItemCode nvarchar(max)
	DECLARE @locationBarcode nvarchar(max)
	DECLARE @print bit
	DECLARE @printerName nvarchar(max)
	DECLARE @responseCode int
	DECLARE @responseJSON nvarchar(max)
	SELECT @userID =  (SELECT ID FROM Users WHERE Name = (SELECT Value FROM @input WHERE Name = 'User'))    
	SELECT @trackingEntityBarcode = [Value] FROM @input WHERE [Name] = 'CTrackingEntity'
	SELECT @Location = [Value] FROM @input WHERE [Name] = 'CLocation'
	SELECT @Batch = [Value] FROM @input WHERE [Name] = 'CBatch'
	SELECT @MasterItem = [Value] FROM @input WHERE [Name] = 'CMasterItem'
	SELECT @Qty = [Value] FROM @input WHERE [Name] = 'CQty'
	SELECT @CurrentLocation = Barcode FROM Location WHERE ID = (SELECT Location_id FROM TrackingEntity WHERE Barcode = @trackingEntityBarcode)
	SELECT @CurrentMasterItem = Code FROM MasterItem WHERE ID = (SELECT MasterItem_id FROM TrackingEntity WHERE Barcode = @trackingEntityBarcode)
	SELECT @CurrentQty = Qty FROM TrackingEntity WHERE Barcode = @trackingEntityBarcode
	UPDATE TrackingEntity SET Batch = @Batch WHERE Barcode = @trackingEntityBarcode
	IF (SELECT StockTake FROM TrackingEntity WHERE Barcode = @trackingEntityBarcode) = 1
	BEGIN
		SELECT @comment = NULL
		SELECT @processName = 'STOCKTAKEHOLD_CUSTOM'
		SELECT @reference = NULL
		EXECUTE [dbo].[clr_StockTakeRelease] 
		   @userID
		  ,@comment
		  ,@processName
		  ,@reference
		  ,@trackingEntityBarcode
		  ,@responseCode OUTPUT
		  ,@responseJSON OUTPUT
	END
	IF @CurrentLocation <> @Location
	BEGIN
		SELECT @inventoryIdentifier = @trackingEntityBarcode
		SELECT @locationIdentifier = @Location
		SELECT @comment = NULL
		SELECT @reference = NULL
		SELECT @integrationReference = NULL
		SELECT @processName = 'STOCKTAKEHOLD_CUSTOM'
		EXECUTE [dbo].[clr_Move] 
		   @userID
		  ,@inventoryIdentifier
		  ,@locationIdentifier
		  ,@comment
		  ,@reference
		  ,@integrationReference
		  ,@processName
		  ,@responseCode OUTPUT
		  ,@responseJSON OUTPUT
	END
	IF @Qty <> @CurrentQty
	BEGIN
		IF @Qty > @CurrentQty
		BEGIN
			SELECT @AdjustmentType = 'QtyIncrease'
			SELECT @AdjustmentQty = @Qty - @CurrentQty
		END
		ELSE
		BEGIN
			SELECT @AdjustmentType = 'QtyDecrease'
			SELECT @AdjustmentQty = @CurrentQty - @Qty
		END
		SELECT @inventoryIdentifier = @trackingEntityBarcode
		SELECT @Qty = @AdjustmentQty
		SELECT @comment = NULL
		SELECT @reference = NULL
		SELECT @integrationReference = NULL
		SELECT @processName = 'STOCKTAKEHOLD_CUSTOM'
		EXECUTE [dbo].[clr_Adjustment] 
		   @userID
		  ,@inventoryIdentifier
		  ,@qty
		  ,@comment
		  ,@reference
		  ,@adjustmentType
		  ,@integrationReference
		  ,@processName
		  ,@responseCode OUTPUT
		  ,@responseJSON OUTPUT
	END
	IF @MasterItem <> @CurrentMasterItem
	BEGIN
		SELECT @masterItemCode = @MasterItem
		SELECT @locationBarcode = @Location
		SELECT @comment = ''
		SELECT @reference = ''
		SELECT @integrationReference = ''
		SELECT @processName = 'STOCKTAKEHOLD_CUSTOM'
		SELECT @print = ''
		SELECT @printerName = ''
		EXECUTE [dbo].[clr_Reclassify] 
		   @userID
		  ,@masterItemCode
		  ,@trackingEntityBarcode
		  ,@locationBarcode
		  ,@comment
		  ,@reference
		  ,@integrationReference
		  ,@processName
		  ,@print
		  ,@printerName
		  ,@responseCode OUTPUT
		  ,@responseJSON OUTPUT
	END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
