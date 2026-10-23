CREATE PROCEDURE [dbo].[Prescript_Receiving_ExpiryDate] (
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
DECLARE @ExistingExpiryDate datetime
DECLARE @ExpiryDate varchar(50)
DECLARE @TrackingEntityID bigint
DECLARE @TrackingEntityBarcode varchar(50) = (SELECT Value FROM @input WHERE Name = 'UseBarcode')
	SELECT
	@TrackingEntityID = ID,
	@ExistingExpiryDate = ExpiryDate
	FROM TrackingEntity
	WHERE Barcode = @TrackingEntityBarcode
	IF ISNULL(@TrackingEntityID, 0) <> 0
	BEGIN
		SELECT 
		@stepInput = CONVERT(VARCHAR(10), @ExistingExpiryDate, 112)
		
	END
	
	
	SELECT @message = @stepInput
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
