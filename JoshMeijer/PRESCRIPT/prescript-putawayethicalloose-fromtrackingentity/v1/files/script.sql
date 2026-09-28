CREATE PROCEDURE [dbo].[Prescript_PutawayEthicalLoose_FromTrackingEntity] (
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
DECLARE @MasterItemID bigint
,@MasterItem varchar(50)
,@Location varchar(50) = 'ETHICAL RECEIVING',
@TrackingEntityBarcode varchar(50)
BEGIN TRY
	SELECT TOP 1 @MasterItemID = MasterItem_id FROM MasterItemAlias_View WHERE Code = @stepInput
	IF ISNULL(@MasterItemID, 0) = 0
	BEGIN
		SELECT TOP 1 @MasterItemID = MasterItem_id FROM MasterItemAlias_View WHERE Code = SUBSTRING(@stepInput, 1, LEN(@stepInput) - 1)
	END 
	IF ISNULL(@MasterItemID, 0) = 0
	BEGIN
		SELECT TOP 1 @MasterItemID = MasterItem_id FROM MasterItemAlias_View WHERE Code = CONCAT('0', @stepInput)
	END
	IF ISNULL(@MasterItemID, 0) = 0
	BEGIN
		SELECT TOP 1 @MasterItemID = MasterItem_id FROM MasterItemAlias_View WHERE Code = CONCAT(@stepInput, '5')
	END
	IF ISNULL(@MasterItemID, 0) <> 0
	BEGIN
		SELECT @MasterItem = Code FROM MasterItem WHERE ID = @MasterItemID
		IF ISNULL(@MasterItem, '') = ''
		BEGIN
			RAISERROR('Cannot determine master item', 16, 1)
		END
	END
	ELSE
	BEGIN
		SELECT @MasterItem = @stepInput;
	END
	SELECT TOP 1 
	@TrackingEntityBarcode = TE.Barcode
	FROM TrackingEntity TE
	INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
	INNER JOIN [Location] L ON TE.Location_id = L.ID
	WHERE
	MI.Code = @MasterItem
	AND L.Barcode = @Location
	AND TE.InStock = 1
	AND TE.Batch IS NULL
	AND TE.ExpiryDate IS NULL
	AND TE.BelongsToEntity_id IS NULL
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
