CREATE PROCEDURE [dbo].[PrescriptLoadTruckTrackingEntity] (
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
DECLARE @User varchar(50)
DECLARE @TrackingEntity varchar(30)
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
SELECT @TrackingEntity =  @stepInput
IF @TrackingEntity LIKE 'T%'
BEGIN
	SELECT @Valid = 0
	SELECT @message = 'You can only  load a Package Barcode, not a stock barcode'
END
ELSE
BEGIN
	SELECT @Valid = 1
	SELECT @message = ''
	UPDATE TrackingEntity SET InStock = 1 WHERE Barcode = @TrackingEntity
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
