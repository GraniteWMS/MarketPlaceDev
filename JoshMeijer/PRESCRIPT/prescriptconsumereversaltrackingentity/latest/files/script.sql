CREATE PROCEDURE [dbo].[PrescriptConsumeReversalTrackingEntity] (
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
SELECT @stepInput = UPPER(Value) FROM @input WHERE Name = 'StepInput' 



DECLARE @Document varchar(50)

SELECT @Document = UPPER(Value) FROM @input WHERE Name = 'Document'

IF EXISTS(SELECT ID FROM TrackingEntity WHERE Barcode = @stepInput)
BEGIN
	IF EXISTS(SELECT DocumentNumber FROM WebTemplateConsumeReversal WHERE DocumentNumber = @Document AND TrackingEntity = @stepInput)
	BEGIN
		SELECT @valid = 1
		SELECT @message = ''
	END
	ELSE
	BEGIN
		SELECT @valid = 0
		SELECT @message = CONCAT('The scanned Tracking Entity has not been consumed for WorkOrder ',UPPER(@Document))
	END
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = 'The scanned barcode is not a valid Tracking Entity'
END





	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
