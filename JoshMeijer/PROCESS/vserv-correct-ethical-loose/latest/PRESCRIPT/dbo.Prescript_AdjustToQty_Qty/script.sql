CREATE PROCEDURE [dbo].[Prescript_AdjustToQty_Qty] (
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
DECLARE
@TrackingEntity varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'TrackingEntity'),
@QtyToAdjustTo decimal(19, 4) = CONVERT(DECIMAL(19, 4), @stepInput),
@QtyToAdjustBy decimal(19, 4),
@CurrentQty decimal(19, 4),
@AdjustmentType varchar(50);
BEGIN TRY
	SELECT @CurrentQty = Qty FROM TrackingEntity WHERE Barcode = @TrackingEntity;
	SELECT @AdjustmentType = IIF((@CurrentQty - @QtyToAdjustTo) < 0, 'QtyIncrease', 'QtyDecrease');
	SET @QtyToAdjustBy = ABS(@CurrentQty - @QtyToAdjustTo);
	INSERT INTO @Output
	SELECT 'Type', @AdjustmentType;
	SET @stepInput = @QtyToAdjustBy;
	SELECT 
	@valid = 1,
	@message = @stepInput;
END TRY
BEGIN CATCH
	SELECT 
	@valid = 0,
	@message = ERROR_MESSAGE();
END CATCH
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
