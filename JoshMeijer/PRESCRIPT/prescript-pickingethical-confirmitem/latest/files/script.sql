CREATE PROCEDURE [dbo].[Prescript_PickingEthical_ConfirmItem] (
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
,@Document varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Document')
,@CarryingEntity varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'TrackingEntity')
,@PCrate varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Comment')
,@Location varchar(50)
,@LocationType varchar(50)
,@ItemCodeOnCarryingEntity varchar(50)
,@EthicalPackingLocationID bigint = (SELECT ID FROM [Location] WHERE Barcode = 'ETHICAL PACKING')
SELECT
@Location = L.Barcode,
@LocationType = L.[Type],
@ItemCodeOnCarryingEntity = MI.Code
FROM CarryingEntity CE
INNER JOIN [Location] L ON CE.Location_id = L.ID
INNER JOIN TrackingEntity TE ON TE.BelongsToEntity_id = CE.ID AND TE.InStock = 1 AND TE.Qty > 0
INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
WHERE CE.Barcode = @CarryingEntity
BEGIN TRY
	IF ISNULL(@stepInput, '') = 'CLOSE PICKING CRATE'
	BEGIN
		IF NOT EXISTS(SELECT * FROM Custom_VW_Ethical_PickingQuantitiesNotPacked WHERE PCrate = @PCrate) 
		BEGIN
			RAISERROR('No stock has been picked on crate %s', 16, 1, @PCrate)
		END
		UPDATE CarryingEntity
		SET Location_id = @EthicalPackingLocationID
		WHERE Barcode = @PCrate
		RAISERROR('Picking crate %s has been closed and moved to ETHICAL PACKING', 16, 1, @PCrate)
	END
	IF ISNULL(@stepInput, '') <> @CarryingEntity
	BEGIN
	
		IF ISNULL(@LocationType, '') <> 'ETHL_PICKFACE'
		BEGIN
			RAISERROR('You can only pick from locations that are of type ETHL_PICKFACE', 16, 1)
		END
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
		IF @MasterItem <> @ItemCodeOnCarryingEntity
		BEGIN 
			RAISERROR('The item code you scanned (%s) does not match the item code (%s) on the box you scanned (%s)', 16, 1, @MasterItem, @ItemCodeOnCarryingEntity, @CarryingEntity)
		END
	END
	INSERT INTO @Output
	SELECT 'Location', @Location
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
