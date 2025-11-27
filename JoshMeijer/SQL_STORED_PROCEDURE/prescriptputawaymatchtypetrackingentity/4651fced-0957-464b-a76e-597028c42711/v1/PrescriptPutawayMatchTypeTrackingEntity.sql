CREATE PROCEDURE [dbo].[PrescriptPutawayMatchTypeTrackingEntity] (
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
DECLARE @MasterItemMatchType bit
DECLARE @MasterItemType varchar(50)
DECLARE @LocationIdentifier varchar(50)
DECLARE @LocationType varchar(50)

SELECT @LocationIdentifier = [Value] FROM @input WHERE [Name] = 'Location'

SELECT @MasterItemMatchType = ISNULL(EnforceTypeMatchInLocations, 0), @MasterItemType = [Type]
FROM TrackingEntity INNER JOIN
MasterItem ON TrackingEntity.MasterItem_id = MasterItem.ID
WHERE TrackingEntity.Barcode = @TrackingEntityBarcode

IF @MasterItemMatchType = 0
BEGIN
	SELECT @valid = 1
END
ELSE
BEGIN
	IF EXISTS(SELECT ID FROM [Location] WHERE Barcode = @LocationIdentifier)
	BEGIN
		SELECT @LocationType = [Type] FROM [Location] WHERE Barcode = @LocationIdentifier
	END
	ELSE
	BEGIN
		SELECT @LocationType = [Type] FROM [Location] WHERE [Name] = @LocationIdentifier
	END

	IF ISNULL(@MasterItemType, '') <> ISNULL(@LocationType, '')
	BEGIN
		SELECT @valid = 0
		SELECT @message = 'MasterItem Type does not match Location Type'
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
