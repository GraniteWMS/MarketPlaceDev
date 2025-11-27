CREATE PROCEDURE [dbo].[PrescriptPalletizeCheckContentsTrackingEntity] (
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




DECLARE @CarryingEntityBarcode varchar(50)
DECLARE @CarryingEntity_id bigint
DECLARE @TrackingEntityBarcode varchar(50)
DECLARE @TrackingEntityMasterItem_id bigint

SELECT @CarryingEntityBarcode = [Value] FROM @input WHERE [Name] = 'CarryingEntity'
SELECT @CarryingEntity_id = ID FROM CarryingEntity WHERE Barcode = @CarryingEntityBarcode

SELECT @TrackingEntityMasterItem_id = MasterItem_id FROM TrackingEntity WHERE Barcode = @stepInput

IF EXISTS(SELECT ID FROM TrackingEntity WHERE BelongsToEntity_id = @CarryingEntity_id AND MasterItem_id <> @TrackingEntityMasterItem_id)
BEGIN
	SELECT @valid = 0
	SELECT @message = 'This pallet contains another MasterItem'
END
ELSE
BEGIN
	DECLARE @CurrentCountOnPallet int
	DECLARE @MaximumAllowedOnPallet int

	SELECT @CurrentCountOnPallet = COUNT(ID) FROM TrackingEntity WHERE BelongsToEntity_id = @CarryingEntity_id
	SELECT @MaximumAllowedOnPallet = ISNULL(PackageType, 0) FROM MasterItem WHERE ID = @TrackingEntityMasterItem_id

	IF @MaximumAllowedOnPallet > 0 AND @MaximumAllowedOnPallet = @CurrentCountOnPallet
	BEGIN
		SELECT @valid = 0
		SELECT @message = 'This pallet is already at the maximum specified for this MasterItem'
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
