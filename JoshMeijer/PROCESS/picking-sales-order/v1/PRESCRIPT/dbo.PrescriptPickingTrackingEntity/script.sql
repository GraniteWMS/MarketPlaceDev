CREATE PROCEDURE [dbo].[PrescriptPickingTrackingEntity] (
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
DECLARE @LocationBarcode varchar(30)
SELECT @LocationBarcode =  Location.Barcode 
FROM TrackingEntity LEFT JOIN 
     Location ON TrackingEntity.Location_id = Location.ID
WHERE TrackingEntity.Barcode = @stepInput
IF (@LocationBarcode in ('RECEIVING'))
BEGIN 
SELECT @valid = 0
SELECT @message = 'Cannot pick from Receiving. Move to Pickface.'
END 
ELSE
BEGIN 
SELECT @valid = 1
SELECT @message = ''
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
