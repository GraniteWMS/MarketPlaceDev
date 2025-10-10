CREATE PROCEDURE [dbo].[PrescriptTakeon_LOC_MIMasterItem] (
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

DECLARE @LocationName varchar(50)
DECLARE @TrackingEntityBarcode varchar (50)
DECLARE @LocationBarcode varchar (30)
DECLARE @MasterItemCode varchar (40)

SELECT @LocationName = Value FROM @input WHERE Name = 'Location' 
SELECT @LocationBarcode = Barcode FROM Location WHERE Name = @LocationName
SELECT @MasterItemCode = @stepInput

IF EXISTS(SELECT ID FROM MasterItem WHERE Code = @MasterItemCode AND isActive = 1)
BEGIN

	SELECT @TrackingEntityBarcode = CONCAT(@LocationBarcode, '_', @MasterItemCode)

	IF EXISTS(SELECT ID FROM TrackingEntity WHERE Barcode = @TrackingEntityBarcode)
	BEGIN

		SELECT @valid = 0
		SELECT @message = CONCAT(@TrackingEntityBarcode, ' already exists. Use Replenish or Adjustment')

	END
	ELSE
	BEGIN

		SELECT @valid = 1
		SELECT @message = ''

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
