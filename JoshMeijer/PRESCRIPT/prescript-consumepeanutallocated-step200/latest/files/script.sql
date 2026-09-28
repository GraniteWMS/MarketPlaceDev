CREATE PROCEDURE [dbo].[Prescript_ConsumePeanutAllocated_Step200] (
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
@TrackingEntity varchar(100) = (SELECT [Value] FROM @input WHERE [Name] = 'TrackingEntity'),
@TrackingEntityID bigint
SELECT 
@TrackingEntityID = ID
FROM TrackingEntity 
WHERE Barcode = @TrackingEntity
BEGIN TRY
	UPDATE Custom_TrackingEntityAllocation
	SET [Status] = 'PICKED'
	WHERE Batch = ISNULL(@Batch, '') 
	AND TrackingEntity_id = @TrackingEntityID 
	AND [Status] = 'ALLOCATED'
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
