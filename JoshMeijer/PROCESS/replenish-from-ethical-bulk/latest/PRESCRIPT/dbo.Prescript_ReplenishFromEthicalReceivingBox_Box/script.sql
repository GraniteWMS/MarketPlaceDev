CREATE PROCEDURE [dbo].[Prescript_ReplenishFromEthicalReceivingBox_Box] (
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
DECLARE @FromLocationType varchar(50),
@PhysicalType varchar(50)
SELECT 
@FromLocationType = L.[Type],
@PhysicalType = CE.PhysicalType
FROM CarryingEntity CE 
INNER JOIN [Location] L ON CE.Location_id = L.ID
WHERE CE.Barcode = @stepInput
BEGIN TRY
	IF ISNULL(@PhysicalType, '') <> 'ETHL_REC'
	BEGIN
		RAISERROR('Barcode %s must be a receiving box', 16, 1, @stepInput)
	END
	IF ISNULL(@FromLocationType, '') <> 'ETHL_BULK'
	BEGIN
		RAISERROR('Barcode location must be of type ETHL_BULK', 16, 1)
	END
	SELECT 
	@valid = 1,
	@message = @stepInput
END TRY
BEGIN CATCH
	SELECT 
	@valid = 0,
	@message = ERROR_MESSAGE()
END CATCH
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
