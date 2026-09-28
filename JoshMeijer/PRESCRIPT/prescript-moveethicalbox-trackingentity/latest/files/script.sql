CREATE PROCEDURE [dbo].[Prescript_MoveEthicalBox_TrackingEntity] (
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
DECLARE @CarryingEntityID bigint,
@CarryingEntityBarcode varchar(50) = @stepInput,
@CurrentBoxLocation varchar(50)
BEGIN TRY
	SELECT 
	@CarryingEntityID = CE.ID,
	@CurrentBoxLocation = L.Barcode
	FROM dbo.CarryingEntity CE
	INNER JOIN [Location] L ON CE.Location_id = L.ID
	WHERE CE.Barcode = @CarryingEntityBarcode
	IF ISNULL(@CarryingEntityBarcode, '') NOT LIKE 'ETHL%'
	BEGIN
		RAISERROR('Must be a Ethical (ETHL) barcode', 16, 1)
	END
	IF ISNULL(@CarryingEntityID, 0) = 0
	BEGIN
		RAISERROR('ETHL barcode %s does not exist', 16, 1, @stepInput)
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
