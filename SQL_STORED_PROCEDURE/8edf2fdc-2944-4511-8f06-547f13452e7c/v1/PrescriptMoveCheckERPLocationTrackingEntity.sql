CREATE PROCEDURE [dbo].[PrescriptMoveCheckERPLocationTrackingEntity] (
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




DECLARE @ToLocation varchar(50)
DECLARE @ToLocationERPLocation varchar(50)
DECLARE @ERPLocationsMatch bit = 1

SELECT @ToLocation = [Value] FROM @input WHERE [Name] = 'Location'

IF EXISTS(SELECT ID FROM [Location] WHERE Barcode = @ToLocation)
BEGIN
	SELECT @ToLocationERPLocation = ERPLocation
	FROM [Location]
	WHERE Barcode = @ToLocation
END
ELSE 
BEGIN
	SELECT @ToLocationERPLocation = ERPLocation
	FROM [Location]
	WHERE [Name] = @ToLocation
END

IF EXISTS(SELECT ID FROM TrackingEntity WHERE Barcode = @stepInput)
BEGIN
	DECLARE @TrackingEntityERPLocation varchar(50)
	
	SELECT @TrackingEntityERPLocation = [Location].ERPLocation
	FROM TrackingEntity INNER JOIN
	[Location] ON TrackingEntity.Location_id = [Location].ID
	WHERE TrackingEntity.Barcode = @stepInput

	IF ISNULL(@TrackingEntityERPLocation, '') <> ISNULL(@ToLocationERPLocation, '')
	BEGIN
		SELECT @ERPLocationsMatch = 0
	END
END
ELSE IF EXISTS(SELECT ID FROM CarryingEntity WHERE Barcode = @stepInput)
BEGIN
	DECLARE @CarryingEntity_id bigint
	DECLARE @CarryingEntityLocation_id bigint
	DECLARE @CarryingEntityERPLocation varchar(50)

	SELECT @CarryingEntity_id = ID, @CarryingEntityLocation_id = Location_id FROM CarryingEntity WHERE Barcode = @stepInput
	SELECT @CarryingEntityERPLocation = ERPLocation FROM [Location] WHERE ID = @CarryingEntityLocation_id

	IF ISNULL(@CarryingEntityERPLocation, '') <> ISNULL(@ToLocationERPLocation, '')
	BEGIN
		SELECT @ERPLocationsMatch = 0
	END
	ELSE IF EXISTS(
			SELECT TrackingEntity.ID 
			FROM TrackingEntity INNER JOIN
			[Location] ON TrackingEntity.Location_id = [Location].ID
			WHERE ISNULL([Location].ERPLocation, '') <> ISNULL(@ToLocationERPLocation, '') AND BelongsToEntity_id = @CarryingEntity_id
		)
	BEGIN
		SELECT @ERPLocationsMatch = 0
	END
END

IF @ERPLocationsMatch = 0 
BEGIN
	SELECT @valid = 0
	SELECT @message = 'You cannot move stock between ERPLocations. Use Transfer instead.'
END
ELSE
BEGIN
	SELECT @valid = 1
END





	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
