CREATE PROCEDURE [dbo].[PrescriptAdjustToQtyTrackingEntity] (
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




DECLARE @TrackingEntityInstock bit

IF NOT EXISTS(SELECT ID FROM TrackingEntity WHERE Barcode = @stepInput)
BEGIN
	SELECT @valid = 0
	SELECT @message = CONCAT('TrackingEntity ', @stepInput, ' not found')
END
ELSE
BEGIN
	SELECT @valid = 1

	SELECT @TrackingEntityInstock = InStock
	FROM TrackingEntity
	WHERE Barcode = @stepInput

	IF @TrackingEntityInstock = 0
	BEGIN
		SELECT @valid = 0
		SELECT @message = CONCAT('TrackingEntity ', @stepInput, ' not in stock')
	END
END





	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
