CREATE PROCEDURE [dbo].[Prescript_PutawayBulk_FromTrackingEntity] (
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
@MasterItem varchar(50) = @stepInput
,@Location varchar(50) = 'RECEIVING',
@TrackingEntityBarcode varchar(50)
BEGIN TRY
	SELECT TOP 1 
	@TrackingEntityBarcode = TE.Barcode
	FROM TrackingEntity TE
	INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
	INNER JOIN [Location] L ON TE.Location_id = L.ID
	WHERE
	MI.Code = @MasterItem
	AND L.Barcode = @Location
	AND TE.InStock = 1
	AND TE.Qty > 0
	IF ISNULL(@TrackingEntityBarcode, '') = ''
	BEGIN
		RAISERROR('Could not find barcode in %s of item %s', 16, 1, @Location, @MasterItem)
	END
	
	SET @stepInput = @TrackingEntityBarcode
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