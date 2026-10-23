CREATE PROCEDURE [dbo].[Prescript_MoveEthicalBox_Location] (
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
DECLARE
@CarryingEntityBarcode varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'TrackingEntity'),
@CurrentBoxLocation varchar(50),
@ToLocation varchar(50) = @stepInput,
@ToLocationType varchar(50)
BEGIN TRY
	SELECT 
	@CurrentBoxLocation = L.Barcode
	FROM dbo.CarryingEntity CE
	INNER JOIN [Location] L ON CE.Location_id = L.ID
	WHERE CE.Barcode = @CarryingEntityBarcode
	SELECT
	@ToLocationType = [Type]
	FROM [Location]
	WHERE Barcode = @ToLocation
	IF ISNULL(@ToLocationType, '') NOT LIKE 'ETHL%'
	BEGIN
		RAISERROR('Location %s is not an ethical location', 16, 1, @ToLocation)
	END
	IF ISNULL(@ToLocation, '') = @CurrentBoxLocation
	BEGIN
		RAISERROR('%s is already in location %s', 16, 1, @CarryingEntityBarcode, @CurrentBoxLocation)
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
