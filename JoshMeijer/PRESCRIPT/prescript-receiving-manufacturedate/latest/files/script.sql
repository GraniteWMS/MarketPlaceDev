CREATE PROCEDURE [dbo].[Prescript_Receiving_ManufactureDate] (
   @input dbo.ScriptInputParameters READONLY
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max) 
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @ExistingManufactureDate datetime
DECLARE @ManufactureDate varchar(50)
DECLARE @TrackingEntityID bigint
DECLARE @TrackingEntityBarcode varchar(50) = (SELECT Value FROM @input WHERE Name = 'UseBarcode')
	SELECT
	@TrackingEntityID = ID,
	@ExistingManufactureDate = ManufactureDate
	FROM TrackingEntity
	WHERE Barcode = @TrackingEntityBarcode
	IF ISNULL(@TrackingEntityID, 0) <> 0
	BEGIN
		IF @ExistingManufactureDate IS NULL
		BEGIN
			UPDATE TrackingEntity
			SET ManufactureDate = TRY_CONVERT(DATE, @stepInput)
			WHERE ID = @TrackingEntityID
			INSERT INTO @Output
			SELECT 'Comment', @stepInput
		END
		ELSE
		BEGIN
			INSERT INTO @Output
			SELECT 'Comment', @stepInput
			SELECT @stepInput = CONVERT(VARCHAR(10), @ExistingManufactureDate, 112)
			
		END
		
	END
	
	
	SELECT @message = @stepInput
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
