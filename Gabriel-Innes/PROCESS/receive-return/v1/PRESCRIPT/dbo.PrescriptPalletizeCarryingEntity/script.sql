CREATE PROCEDURE [dbo].[PrescriptPalletizeCarryingEntity] (
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
DECLARE @CarryingEntityBarcode varchar(30) = @stepInput
IF (@CarryingEntityBarcode = 'NEW')
BEGIN
	SELECT @valid = 0
	SELECT @message = 'Please can an existing label.'
END
ELSE IF (@CarryingEntityBarcode NOT LIKE 'PL________' AND @CarryingEntityBarcode NOT LIKE '')
BEGIN
	SELECT @valid = 0
	SELECT @message = @CarryingEntityBarcode + ' is not in the correct format PL00000000'
END
ELSE
BEGIN 
	SELECT @valid = 1
	SELECT @message = ''
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
