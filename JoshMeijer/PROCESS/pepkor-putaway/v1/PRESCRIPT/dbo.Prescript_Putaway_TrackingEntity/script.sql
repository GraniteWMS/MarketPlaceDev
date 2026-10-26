CREATE PROCEDURE [dbo].[Prescript_Putaway_TrackingEntity] (
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
@TrackingEntityBarcode varchar(50) = @stepInput,
@CurrentTrackingEntityLocation varchar(50)
BEGIN TRY
	SELECT 
	@CurrentTrackingEntityLocation = L.Barcode
	FROM dbo.TrackingEntity TE
	INNER JOIN [Location] L ON TE.Location_id = L.ID
	WHERE TE.Barcode = @TrackingEntityBarcode
	IF @CurrentTrackingEntityLocation <> 'RECEIVING'
	BEGIN
		RAISERROR('Barcode %s must be in RECEIVING', 16, 1, @stepInput)
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