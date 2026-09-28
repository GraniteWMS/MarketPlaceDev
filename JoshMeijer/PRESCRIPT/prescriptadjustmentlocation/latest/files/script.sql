CREATE PROCEDURE [dbo].[PrescriptAdjustmentLocation] (
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
DECLARE @TrackingEntity varchar(50)
DECLARE @MasterItemCode varchar(50)
SELECT @MasterItemCode = Value FROM @input WHERE Name = 'MasterItem' 
IF EXISTS(SELECT ID FROM Location WHERE Barcode = @stepInput)
BEGIN
		SELECT @TrackingEntity = CONCAT(@stepInput,'_',@MasterItemCode)
		IF EXISTS(SELECT ID FROM TrackingEntity WHERE Barcode = @TrackingEntity)
		BEGIN
			SELECT @message = 'TrackingEntity is: ' + @TrackingEntity
		END
		ELSE
		BEGIN
			SELECT @message = @TrackingEntity + ' will be created'
		END
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = CONCAT(@stepInput, ' is not a valid Location Barcode')
END
	INSERT INTO @Output
	SELECT 'TrackingEntity',@TrackingEntity
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
