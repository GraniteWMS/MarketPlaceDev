create PROCEDURE [dbo].[PrescriptPutawayMatchCategoryTrackingEntity] (
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




DECLARE @TrackingEntityBarcode varchar(50) = @stepInput
DECLARE @MasterItemMatchCategory bit
DECLARE @MasterItemCategory varchar(50)
DECLARE @LocationIdentifier varchar(50)
DECLARE @LocationCategory varchar(50)

SELECT @LocationIdentifier = [Value] FROM @input WHERE [Name] = 'Location'

SELECT @MasterItemMatchCategory = ISNULL(EnforceCategoryMatchInLocations, 0), @MasterItemCategory = Category
FROM TrackingEntity INNER JOIN
MasterItem ON TrackingEntity.MasterItem_id = MasterItem.ID
WHERE TrackingEntity.Barcode = @TrackingEntityBarcode

IF @MasterItemMatchCategory = 0
BEGIN
	SELECT @valid = 1
END
ELSE
BEGIN
	IF EXISTS(SELECT ID FROM [Location] WHERE Barcode = @LocationIdentifier)
	BEGIN
		SELECT @LocationCategory = Category FROM [Location] WHERE Barcode = @LocationIdentifier
	END
	ELSE
	BEGIN
		SELECT @LocationCategory = Category FROM [Location] WHERE [Name] = @LocationIdentifier
	END

	IF ISNULL(@MasterItemCategory, '') <> ISNULL(@LocationCategory, '')
	BEGIN
		SELECT @valid = 0
		SELECT @message = 'MasterItem Category does not match Location Category'
	END
	ELSE
	BEGIN
		SELECT @valid = 1
	END
END






	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
