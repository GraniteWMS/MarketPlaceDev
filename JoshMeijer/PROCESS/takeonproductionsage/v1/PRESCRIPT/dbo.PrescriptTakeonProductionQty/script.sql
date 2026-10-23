CREATE PROCEDURE [dbo].[PrescriptTakeonProductionQty] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max), 
  Value varchar(max)
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
	SELECT @valid = 1
	SELECT @message = @stepInput
IF ISNUMERIC(@stepInput) = 0
BEGIN
	SELECT @valid = 0
	SELECT @message = 'Please enter a number'
END
ELSE
IF CONVERT(int,@stepInput) > 1000000
BEGIN
	SELECT @valid =0
	SELECT @message = 'The Quantity cannot be over 1 Million'
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
