CREATE PROCEDURE [dbo].[Prescript_PackingEthical_Qty] (
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
SELECT @stepInput = UPPER(Value) FROM @input WHERE Name = 'StepInput' 
DECLARE
@PCrateBarcode varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'CarryingEntity'),
@TotalPickedQty decimal(19, 4)
SELECT @TotalPickedQty = SUM(PickedQty)
FROM Custom_VW_Ethical_PickingQuantitiesNotPacked
WHERE PCrate = @PCrateBarcode
BEGIN TRY
	IF ISNULL(@TotalPickedQty, 0) = 0
	BEGIN
		RAISERROR('Nothing has been picked on %s', 16, 1, @PCrateBarcode)
	END
	IF @TotalPickedQty <> ISNULL(TRY_CONVERT(DECIMAL(19, 4), @stepInput), 0)
	BEGIN 
		RAISERROR('The amount you counted does not match the amount that was picked', 16, 1)
	END
	SELECT 
	@valid = 1,
	@message = @stepInput
END TRY
BEGIN CATCH
	SELECT 
	@valid = 0,
	@message = ERROR_MESSAGE()
END CATCH
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
