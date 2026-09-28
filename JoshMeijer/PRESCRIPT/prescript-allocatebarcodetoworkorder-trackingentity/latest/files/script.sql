CREATE PROCEDURE [dbo].[Prescript_AllocateBarcodeToWorkOrder_TrackingEntity] (
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
@BarcodeID bigint,
@CurrentLocation varchar(50),
@CurrentQty decimal(19, 4),
@IsOnHold bit
SELECT
@BarcodeID = TE.ID,
@CurrentLocation = L.[Name],
@CurrentQty = TE.Qty,
@IsOnHold = TE.OnHold
FROM TrackingEntity TE
INNER JOIN [Location] L ON TE.Location_id = L.ID
WHERE TE.Barcode = @stepInput
AND TE.InStock = 1
BEGIN TRY
	
	IF NOT EXISTS(SELECT ID FROM Custom_VW_AllocatedBarcodes WHERE ID = ISNULL(TRY_CONVERT(BIGINT, @stepInput), 0))
	BEGIN
		IF ISNULL(@BarcodeID, 0) = 0
		BEGIN
			RAISERROR('Barcode %s does not exist', 16, 1, @stepInput)
		END
		IF @CurrentLocation <> 'Peanut Warehouse'
		BEGIN
			RAISERROR('Barcode %s is not in the Peanut Warehouse', 16, 1, @stepInput)
		END
		IF ISNULL(@CurrentQty, 0) = 0
		BEGIN
			RAISERROR('Barcode %s has zero quantity', 16, 1, @stepInput)
		END
		IF @IsOnHold = 1
		BEGIN
			RAISERROR('Barcode %s is onhold', 16, 1, @stepInput)
		END
		INSERT INTO @Output
		SELECT 'Qty', CONVERT(VARCHAR, CONVERT(FLOAT, @CurrentQty))
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
