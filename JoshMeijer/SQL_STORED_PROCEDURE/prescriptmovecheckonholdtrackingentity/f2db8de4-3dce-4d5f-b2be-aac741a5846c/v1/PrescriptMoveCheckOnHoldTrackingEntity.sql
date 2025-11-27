CREATE PROCEDURE [dbo].[PrescriptMoveCheckOnHoldTrackingEntity] (
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




DECLARE @isTrackingEntity bit = 0
DECLARE @isCarryingEntity bit = 0

DECLARE @OnHold bit = 0

IF EXISTS(SELECT ID FROM TrackingEntity WHERE Barcode = @stepInput)
BEGIN
	SELECT @isTrackingEntity = 1
	SELECT @OnHold = OnHold FROM TrackingEntity WHERE Barcode = @stepInput
END
ELSE IF EXISTS(SELECT ID FROM CarryingEntity WHERE Barcode = @stepInput)
BEGIN
	SELECT @isCarryingEntity = 1

	DECLARE @CarryingEntity_id bigint
	SELECT @CarryingEntity_id = ID FROM CarryingEntity WHERE Barcode = @stepInput

	IF EXISTS(SELECT ID FROM TrackingEntity WHERE OnHold = 1 AND BelongsToEntity_id = @CarryingEntity_id)
	BEGIN
		SELECT @OnHold = 1
	END
END

IF @isCarryingEntity = 0 AND @isTrackingEntity = 0
BEGIN
	SELECT @valid = 0
	SELECT @message = CONCAT(@stepInput, ' is not a valid TrackingEntity or CarryingEntity')
END
ELSE
BEGIN
	IF @isTrackingEntity = 1 AND @OnHold = 1
	BEGIN
		SELECT @valid = 0
		SELECT @message = 'TrackingEntity on hold'
	END
	ELSE IF @isCarryingEntity = 1 AND @OnHold = 1
	BEGIN
		SELECT @valid = 0
		SELECT @message = 'CarryingEntity contains on hold TrackingEntities'
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
