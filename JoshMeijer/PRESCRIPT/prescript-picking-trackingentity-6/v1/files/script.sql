CREATE PROCEDURE [dbo].[Prescript_Picking_TrackingEntity] (
   @input dbo.ScriptInputParameters READONLY
)
AS
DECLARE @Output TABLE(
  Name varchar(max),
  Value varchar(max)
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput'
DECLARE @MasterItemCode varchar(30)
DECLARE @FromLocation varchar(20)
DECLARE @TrackingEntityBarcode varchar(20)
DECLARE @Qty decimal(19,4)
SELECT @FromLocation = VALUE FROM @input WHERE Name = 'FromLocation'
DECLARE @LocationType varchar(30) = (SELECT [Type] FROM [Location] WHERE Barcode = @FromLocation)
DECLARE @MasterItem_id bigint;
SELECT @MasterItem_id = ma.MasterItem_id
FROM MasterItemAlias_View ma
WHERE ma.Code = @stepInput;
IF @MasterItem_id IS NULL
BEGIN
    SELECT @MasterItem_id = m.ID
    FROM MasterItem m
    WHERE m.Code = @stepInput
       OR m.FormattedCode = @stepInput;
END
BEGIN TRY
	IF @LocationType = 'BULK' AND @MasterItem_id IS NOT NULL
		RAISERROR('ERROR: Only TrackingEntities are allowed to be scanned in bulk.', 16, 1)
	EXEC Utility_TrackingEntity_Determine
	@MasterItemCode = @stepInput
    ,@LocationBarcode = @FromLocation
	,@TrackingEntityBarcode = @TrackingEntityBarcode OUTPUT
    IF @TrackingEntityBarcode = 'INVALID'
        RAISERROR('ERROR: Item not found in scanned Location %s', 16, 1, @FromLocation)
    SELECT @Qty = Qty 
    FROM TrackingEntity 
    WHERE Barcode = @TrackingEntityBarcode
    IF @Qty < 1
        RAISERROR('ERROR: No Stock Available For Item %s in location %s', 16, 1, @stepInput, @FromLocation)
	SELECT @stepInput = @TrackingEntityBarcode
	,@valid = 1
	,@message = @TrackingEntityBarcode
END TRY
BEGIN CATCH
    SELECT @valid = 0
    ,@message = ERROR_MESSAGE()
END CATCH
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output