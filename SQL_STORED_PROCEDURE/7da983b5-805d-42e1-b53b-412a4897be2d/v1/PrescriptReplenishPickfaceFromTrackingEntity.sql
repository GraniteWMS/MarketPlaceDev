CREATE PROCEDURE [dbo].[PrescriptReplenishPickfaceFromTrackingEntity] (
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




IF NOT EXISTS(SELECT ID FROM TrackingEntity WHERE Barcode = @stepInput AND InStock = 1)
BEGIN
	SELECT @valid = 0
	SELECT @message = CONCAT('TrackingEntity ', @stepInput, ' not found')
END
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
