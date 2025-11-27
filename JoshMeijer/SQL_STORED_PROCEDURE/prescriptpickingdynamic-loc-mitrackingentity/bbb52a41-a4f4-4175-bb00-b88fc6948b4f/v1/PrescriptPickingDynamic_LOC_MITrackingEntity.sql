CREATE PROCEDURE [dbo].[PrescriptPickingDynamic_LOC_MITrackingEntity] (
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

DECLARE @MasterItemCode varchar (40)
DECLARE @LocationIdentifier varchar (40)
DECLARE @TrackingEntityBarcode varchar (60)

SELECT @MasterItemCode = Value FROM @input WHERE Name = 'MasterItem'
SELECT @LocationIdentifier = @stepInput

IF EXISTS(SELECT ID FROM Location WHERE Barcode = @LocationIdentifier OR [Name] = @LocationIdentifier)
BEGIN
	
	SELECT @valid = 1
	SELECT @message = ''

	SELECT @TrackingEntityBarcode = CONCAT(@LocationIdentifier, '_', @MasterItemCode)
	SELECT @stepInput = @TrackingEntityBarcode

END
ELSE
BEGIN
	
	SELECT @valid = 0
	SELECT @message = CONCAT(@LocationIdentifier, ' does not exist')

END

	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput

	SELECT * FROM @Output
