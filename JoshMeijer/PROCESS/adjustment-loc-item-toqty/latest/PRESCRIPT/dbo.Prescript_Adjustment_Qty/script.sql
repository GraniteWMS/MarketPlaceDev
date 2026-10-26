CREATE PROCEDURE [dbo].[Prescript_Adjustment_Qty] (
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
DECLARE @TrackingEntity varchar(50)
DECLARE @TrackingEntityID bigint
DECLARE @AdjustmentType varchar(30)
DECLARE @QtyAdjust Decimal(19,4)
DECLARE @QtyEntered Decimal(19,4)
DECLARE @TrackingEntityQty Decimal(19,4)
DECLARE @Location varchar(30) = (SELECT Value FROM @input WHERE Name = 'Location') 
DECLARE @MasterItemCode varchar(50) = (SELECT Value FROM @input WHERE Name = 'MasterItem')
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
SELECT @QtyEntered = @stepInput
SELECT @TrackingEntity = CONCAT(@Location,'_',@MasterItemCode)
SELECT @TrackingEntityID = ID, @TrackingEntityQty  = Qty FROM TrackingEntity WHERE Barcode = @TrackingEntity
SET @TrackingEntityQty = ISNULL(@TrackingEntityQty, 0)
BEGIN TRY
	
	
	
	SET @QtyAdjust = ABS(@QtyEntered - @TrackingEntityQty)
	IF @QtyEntered = @TrackingEntityQty
		THROW 50000, @TrackingEntity, 1
	SELECT @AdjustmentType = CASE WHEN @QtyEntered > @TrackingEntityQty THEN 'QtyIncrease' ELSE 'QtyDecrease' END
	SELECT @valid = 1,
	@message = CONCAT('Adjusted ', @TrackingEntity, ' to ', @QtyEntered),
	@stepInput = @QtyAdjust
END TRY
BEGIN CATCH
	SELECT @valid = 0,
	@message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Type', @AdjustmentType
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
