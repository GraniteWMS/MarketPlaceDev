CREATE PROCEDURE [dbo].[PrescriptBlindReceivingQty] (
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
IF ISNUMERIC(@stepInput) = 1
BEGIN
	IF CAST(@stepInput AS int) > 10000
	BEGIN
		SELECT @valid = 0
		SELECT @message = 'There is a limit of 10 000 quantity per TrackingEntity Barcode'
	END
	ELSE
	BEGIN
		SELECT @valid = 1
	END
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = 'Please enter a numeric value'
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
