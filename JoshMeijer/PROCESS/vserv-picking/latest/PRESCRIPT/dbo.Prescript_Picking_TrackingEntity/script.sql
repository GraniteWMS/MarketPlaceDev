CREATE PROCEDURE [dbo].[Prescript_Picking_TrackingEntity] (
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
DECLARE @Location varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Location')
DECLARE @ExpiryDate date = (SELECT CONVERT(DATE, [Value]) FROM @input WHERE [Name] = 'Comment')
DECLARE @ExpiryDateAsString varchar(50) = CONVERT(VARCHAR, @ExpiryDate, 111)
DECLARE @LocationID bigint = (SELECT ID FROM [Location] WHERE Barcode = @Location)
DECLARE @MasterItemID bigint
DECLARE @MasterItem varchar(50)
DECLARE @TrackingEntity varchar(50)
BEGIN TRY
	SELECT TOP 1 @MasterItemID = MasterItem_id FROM MasterItemAlias_View WHERE Code = @stepInput
	IF ISNULL(@MasterItemID, 0) = 0
	BEGIN
		SELECT @MasterItemID = ID FROM MasterItem WHERE Code = @stepInput
	END
	IF ISNULL(@MasterItemID, 0) = 0
	BEGIN
		RAISERROR('Item code could not be determined based on input (%s)', 16, 1, @stepInput)
	END
	SELECT @MasterItem = Code FROM MasterItem WHERE ID = @MasterItemID
	SELECT @TrackingEntity = Barcode
	FROM TrackingEntity
	WHERE MasterItem_id = @MasterItemID
	AND Location_id = @LocationID
	AND ExpiryDate IS NOT DISTINCT FROM @ExpiryDate
	AND InStock = 1
	IF ISNULL(@TrackingEntity, '') = ''
	BEGIN
		RAISERROR('Could not find tracking entity in location %s of item code %s with expiry date of %s', 16, 1, @Location, @MasterItem, @ExpiryDateAsString)
	END
	SET @stepInput = @TrackingEntity
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
