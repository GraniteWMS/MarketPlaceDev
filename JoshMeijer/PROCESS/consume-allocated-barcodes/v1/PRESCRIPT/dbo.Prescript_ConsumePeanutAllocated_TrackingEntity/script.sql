CREATE PROCEDURE [dbo].[Prescript_ConsumePeanutAllocated_TrackingEntity] (
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
@TrackingEntityID bigint,
@TrackingEntityQty float,
@IsOnHold bit,
@AllocationID bigint
 SELECT 
 @TrackingEntityID = ID,
 @IsOnHold = OnHold
 FROM TrackingEntity 
 WHERE Barcode = @stepInput
 SELECT 
 @TrackingEntityQty = Qty
 FROM Custom_TrackingEntityAllocation 
 WHERE Batch = ISNULL(@Batch, '') 
 AND TrackingEntity_id = @TrackingEntityID 
 AND [Status] = 'ALLOCATED'
BEGIN TRY
	IF @IsOnHold = 1
	BEGIN
		RAISERROR('Barcode %s is onhold', 16, 1, @stepInput)
	END
	INSERT INTO @Output
	SELECT 'Qty', CONVERT(VARCHAR, @TrackingEntityQty)
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
