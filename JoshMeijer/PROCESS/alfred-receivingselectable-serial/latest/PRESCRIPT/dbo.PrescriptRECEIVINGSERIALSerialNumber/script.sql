CREATE PROCEDURE [dbo].[PrescriptRECEIVINGSERIALSerialNumber] (
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
IF EXISTS(SELECT 1 FROM TrackingEntity WHERE SerialNumber = @stepInput)
BEGIN
		SELECT @valid = 0
		SELECT @message = 'Serial Number already exists'
END
ELSE IF EXISTS(SELECT 1 FROM TrackingEntity WHERE Barcode = @stepInput)
BEGIN
		SELECT @valid = 0
		SELECT @message = 'Serial Number already exists'
END
ELSE
BEGIN
		SELECT @message = 'Serial Captured'
		INSERT INTO @Output
		SELECT 'UseBarcode', @stepInput
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
