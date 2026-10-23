CREATE PROCEDURE [dbo].[PrescriptSpotCheckBarcode] (
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
DECLARE @Cage varchar(100)
	SELECT @Cage = Value from @input where Name = 'Cage'
IF	NOT EXISTS(SELECT 1 FROM Location WHERE (Barcode = @stepInput OR Name = @stepInput) AND Category = @Cage) 
	AND NOT EXISTS (SELECT 1 
					FROM TrackingEntity  
					INNER JOIN Location ON TrackingEntity.Location_id = Location.ID
					WHERE TrackingEntity.Barcode = @stepInput 
						  AND InStock = 1
						  AND Location.Category = @Cage)
	AND NOT EXISTS (SELECT 1 
					FROM TrackingEntity  
					INNER JOIN Location ON TrackingEntity.Location_id = Location.ID
					INNER JOIN MasterItem On TrackingEntity.MasterItem_id = MasterItem.ID
					WHERE MasterItem.Code = @stepInput 
						  AND InStock = 1
						  AND Location.Category = @Cage)
BEGIN 
	SELECT @valid = 0, @message = @stepInput + ' is not a valid Location or Tracking Entity or MasterItem'
END
ELSE
BEGIN 
	SELECT @valid = 1, @message = ''
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
