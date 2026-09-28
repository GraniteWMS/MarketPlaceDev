CREATE PROCEDURE [dbo].[Prescript_Picking_TrackinEntity] (
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
@LocationType varchar(50),
@Location varchar(50)
BEGIN TRY
	SELECT 
	@Location = L.Barcode,
	@LocationType = [Type]
	FROM TrackingEntity TE
	INNER JOIN dbo.[Location] L ON TE.Location_id = L.ID
	WHERE TE.Barcode = @stepInput
	IF ISNULL(@LocationType, '') <> 'BIN'
	BEGIN
		RAISERROR('Location %s must be a BIN location', 16, 1, @stepInput)
	END
	INSERT INTO @Output
	SELECT 'Location', @Location
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