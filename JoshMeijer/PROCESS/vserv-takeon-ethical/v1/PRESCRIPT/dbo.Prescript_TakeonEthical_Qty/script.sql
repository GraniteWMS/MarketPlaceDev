CREATE PROCEDURE [dbo].[Prescript_TakeonEthical_Qty] (
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
@Location varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Location')
,@MasterItem varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'MasterItem')
,@Batch varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Batch')
,@CarryingEntity varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'CarryingEntity')
,@ExpiryDate date = (SELECT TRY_CONVERT(DATE, [Value]) FROM @input WHERE [Name] = 'ExpiryDate')
,@ExistingTrackingEntityWithSameLocationAndExpiryAndBatch varchar(50)
BEGIN TRY
	SELECT TOP 1 @ExistingTrackingEntityWithSameLocationAndExpiryAndBatch = TE.Barcode
	FROM TrackingEntity TE
	INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
	INNER JOIN [Location] L ON TE.Location_id = L.ID
	INNER JOIN CarryingEntity CE ON TE.BelongsToEntity_id = CE.ID
	WHERE 
	MI.Code = @MasterItem
	AND L.Barcode = @Location
	AND CE.Barcode = @CarryingEntity
	AND ExpiryDate IS NOT DISTINCT FROM NULLIF(@ExpiryDate, '1900-01-01')
	AND Batch IS NOT DISTINCT FROM @Batch
	AND TE.Instock = 1
	INSERT INTO @Output
	SELECT 'UseBarcode', @ExistingTrackingEntityWithSameLocationAndExpiryAndBatch
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
