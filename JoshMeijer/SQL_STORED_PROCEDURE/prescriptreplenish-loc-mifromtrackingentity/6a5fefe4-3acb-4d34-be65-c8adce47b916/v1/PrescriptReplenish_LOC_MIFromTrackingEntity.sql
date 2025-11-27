CREATE PROCEDURE [dbo].[PrescriptReplenish_LOC_MIFromTrackingEntity] (
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

DECLARE @FromTrackingEntityBarcode varchar (50)
DECLARE @FromLocationBarcode varchar (30)
DECLARE @MasterItemCode varchar (40)

SELECT @FromLocationBarcode = Value FROM @input WHERE Name = 'FromLocation' 
SELECT @MasterItemCode = @stepInput

IF EXISTS (SELECT ID FROM MasterItem WHERE Code = @MasterItemCode AND isActive = 1)
BEGIN

	SELECT @FromTrackingEntityBarcode = CONCAT(@FromLocationBarcode, '_', @MasterItemCode)
		
	IF EXISTS(SELECT ID FROM TrackingEntity WHERE Barcode = @FromTrackingEntityBarcode)
	BEGIN

		SELECT @stepInput = @FromTrackingEntityBarcode
		
		SELECT @valid = 1
		SELECT @message = ''

	END
	ELSE
	BEGIN

		SELECT @valid = 0
		SELECT @message = CONCAT(@FromTrackingEntityBarcode, ' does not exist')

	END

END
ELSE
BEGIN

	SELECT @valid = 0
	SELECT @message = CONCAT(@MasterItemCode, ' does not exist')

END

	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput

	SELECT * FROM @Output
