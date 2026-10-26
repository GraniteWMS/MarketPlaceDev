CREATE PROCEDURE [dbo].[PrescriptPickingCRTrackingEntity] (
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
DECLARE @Cage varchar(30)
	SELECT @Cage = Value FROM @input WHERE Name = 'Cage'
SELECT @LocationBarcode =  Location.Barcode 
FROM TrackingEntity LEFT JOIN 
     Location ON TrackingEntity.Location_id = Location.ID
WHERE TrackingEntity.Barcode = @stepInput
IF (@LocationBarcode in ('RECEIVING01', 'RECEIVING02', 'DAMAGED', '1-144-1', '1-144-2', '1-144-4', '1-145-1', '1-145-3'))
	BEGIN 
		SELECT @valid = 0
		SELECT @message = 'Cannot pick from Receiving, please move to a Cage.'
	END 
ELSE IF (@Cage = 'DAMAGED' AND @LocationBarcode <> 'DAMAGED')
	BEGIN
		SELECT @valid = 0
		SELECT @message = 'Item not in DAMAGED Location'
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
