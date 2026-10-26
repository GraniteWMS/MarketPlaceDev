CREATE PROCEDURE [dbo].[PrescriptTakeon_LOC_MIQty] (
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
BEGIN TRY
	
	
	
	
	
	
	IF ISNUMERIC(@stepInput) = 0
		RAISERROR('You entered:%s.  The Qty must be Numeric',16,1,@stepInput)
	SELECT @valid = 1
	SELECT @message = ''
END TRY
BEGIN CATCH
	SELECT @valid = 0,@message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
