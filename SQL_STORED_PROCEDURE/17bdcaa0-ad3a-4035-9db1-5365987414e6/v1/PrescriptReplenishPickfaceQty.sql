CREATE PROCEDURE [dbo].[PrescriptReplenishPickfaceQty] (
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




IF ISNUMERIC(@stepInput) = 0
BEGIN
	SELECT @valid = 0
	SELECT @message = 'Not a valid input'
END
ELSE
BEGIN
	DECLARE @qty decimal(19,4) = @stepInput
	DECLARE @FromTrackingEntityBarcode varchar(30)
	DECLARE @FromTrackingEntityQty decimal(19,4)

	SELECT @FromTrackingEntityBarcode = [value] FROM @input WHERE [Name] = 'FromTrackingEntity'
	SELECT @FromTrackingEntityQty = Qty FROM TrackingEntity WHERE Barcode = @FromTrackingEntityBarcode

	IF @qty > @FromTrackingEntityQty
	BEGIN
		SELECT @valid = 0
		SELECT @message = 'Cannot replenish more than qty on TrackingEntity'
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
