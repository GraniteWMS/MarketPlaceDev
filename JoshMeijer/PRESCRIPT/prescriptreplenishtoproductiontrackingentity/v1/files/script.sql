CREATE PROCEDURE [dbo].[PrescriptReplenishToProductionTrackingEntity] (
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
BEGIN TRY
	IF NOT EXISTS(SELECT 1 FROM TrackingEntity TE 
							INNER JOIN Location L ON TE.Location_id = L.ID
							INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
							WHERE TE.Barcode = @stepInput
							AND Qty > 0
							AND L.NonStock = 0
							AND TE.InStock = 1
							AND L.[Type] NOT IN ('PRODUCTION','LINE'))
		RAISERROR('The Scanned TrackingBarocde %s does not exist, or is already in Production or has no stock on it.',16,1,@stepInput)
	SELECT	@valid = 1,
			@message = CONCAT('Trackingentity scanned:', @stepInput)
END TRY
BEGIN CATCH
	SELECT @Valid = 0, @message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
