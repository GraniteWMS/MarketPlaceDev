CREATE PROCEDURE [dbo].[PrescriptReplenishToProductionQty] (
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
BEGIN TRY
	IF ISNUMERIC(@stepInput) = 0
		RAISERROR('Please enter a number',16,1)
	IF CONVERT(int,@stepInput) > 100000
		RAISERROR('The Quantity Should not be over 100000',16,1)
	SELECT	@valid = 1,
			@message = ''
END TRY
BEGIN CATCH
	SELECT @Valid = 0, @message = ERROR_MESSAGE()
END CATCH
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
