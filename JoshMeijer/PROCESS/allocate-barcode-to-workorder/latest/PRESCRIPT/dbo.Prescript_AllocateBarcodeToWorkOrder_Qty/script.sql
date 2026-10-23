CREATE PROCEDURE [dbo].[Prescript_AllocateBarcodeToWorkOrder_Qty] (
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
@Batch varchar(100) = (SELECT [Value] FROM @input WHERE [Name] = 'Batch'),
@TrackingEntity varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'TrackingEntity'),
@AllocationID bigint,
@User varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'User'),
@QtyToAllocate decimal(19, 4) = ISNULL(TRY_CONVERT(DECIMAL(19, 4), @stepInput), 0),
@QtyToDeallocate decimal(19, 4) = ISNULL(TRY_CONVERT(DECIMAL(19, 4), @stepInput), 0),
@QtyAllocatedForID decimal(19, 4),
@QtyAlreadyAllocatedForBarcode decimal(19, 4),
@BarcodeID bigint,
@CurrentQtyOnBarcode decimal(19, 4),
@CurrentDateTime datetime = GETDATE()
IF @TrackingEntity LIKE 'T%'
BEGIN
	SELECT
	@BarcodeID = TE.ID,
	@CurrentQtyOnBarcode = TE.Qty
	FROM TrackingEntity TE
	WHERE TE.Barcode = @TrackingEntity
	SELECT @QtyAlreadyAllocatedForBarcode = SUM(Qty)
	FROM Custom_TrackingEntityAllocation
	WHERE TrackingEntity_id = @BarcodeID AND [Status] = 'ALLOCATED'
	BEGIN TRY
		IF @QtyToAllocate = 0
		BEGIN
			RAISERROR('You cannot allocate zero qty', 16, 1)
		END
		IF (@QtyToAllocate + ISNULL(@QtyAlreadyAllocatedForBarcode, 0)) > @CurrentQtyOnBarcode
		BEGIN
			SET @message = CONCAT('You cannot allocate more stock than what is on barcode ', @TrackingEntity, ' 
			with quantity of ', CONVERT(FLOAT, @CurrentQtyOnBarcode), '. ', 
			CONVERT(FLOAT, ISNULL(@QtyAlreadyAllocatedForBarcode, 0)), ' is already allocated and you are trying to allocate ',
			CONVERT(FLOAT, @QtyToAllocate), ' more.')
			RAISERROR(@message, 16, 1)
		END
		IF EXISTS(SELECT ID FROM Custom_TrackingEntityAllocation WHERE Batch = @Batch AND TrackingEntity_id = @BarcodeID AND [Status] = 'ALLOCATED')
		BEGIN
			UPDATE Custom_TrackingEntityAllocation
			SET Qty += @QtyToAllocate
			WHERE Batch = @Batch AND TrackingEntity_id = @BarcodeID AND [Status] = 'ALLOCATED'
		END
		ELSE
		BEGIN
			INSERT INTO [dbo].[Custom_TrackingEntityAllocation]
			([Date],[Document_id],[DocumentLine_id],[TrackingEntity_id],[Qty],[Status],[Batch],[User])
			SELECT @CurrentDateTime, NULL, NULL, @BarcodeID, @QtyToAllocate, 'ALLOCATED', @Batch, @User
		END
		SELECT 
		@valid = 1,
		@message = CONCAT('Qty of ', CONVERT(FLOAT, @QtyToAllocate), ' of barcode ', @TrackingEntity, ' allocated to batch ', @Batch)
	END TRY
	BEGIN CATCH
		SELECT
		@valid = 0,
		@message = ERROR_MESSAGE()
	END CATCH
END
ELSE
BEGIN
	SELECT 
	@AllocationID = ID,
	@QtyAllocatedForID = Qty
	FROM Custom_TrackingEntityAllocation
	WHERE ID = ISNULL(TRY_CONVERT(BIGINT, @TrackingEntity), 0)
	BEGIN TRY
	
		IF ISNULL(@AllocationID, 0) = 0
		BEGIN
			RAISERROR('Allocation ID could not be found', 16, 1)
		END
		IF @QtyToDeallocate > @QtyAllocatedForID
		BEGIN 
			RAISERROR('You cannot deallocate more than what is allocated', 16, 1)
		END
		IF @QtyToDeallocate = @QtyAllocatedForID
		BEGIN
			DELETE FROM Custom_TrackingEntityAllocation WHERE ID = @AllocationID
		END
		ELSE
		BEGIN
			UPDATE Custom_TrackingEntityAllocation SET Qty -= @QtyToDeallocate WHERE ID = @AllocationID
		END
		SELECT 
		@valid = 1,
		@message = CONCAT('Deallocated qty of ', CONVERT(FLOAT, @QtyToDeallocate))
	END TRY
	BEGIN CATCH
		SELECT
		@valid = 0,
		@message = ERROR_MESSAGE()
	END CATCH	
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
