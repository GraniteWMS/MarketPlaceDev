CREATE PROCEDURE [dbo].[PrescriptPerishablesReceivingManufactureDate] (
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




DECLARE @MasterItem varchar(50)
DECLARE @ShelfLife int
DECLARE @ExpiryDate datetime
DECLARE @ManufactureDate datetime

IF ISNULL(@stepInput, '') = '' 
BEGIN
	
	SELECT @valid = 1
END
ELSE
BEGIN
	IF TRY_CONVERT(datetime, @stepInput, 112) IS NULL
	BEGIN
		SELECT @valid = 0
		SELECT @message = CONCAT(@stepInput, ' is not a valid date')
	END
	ELSE
	BEGIN
		SELECT @MasterItem = [Value] FROM @input WHERE [Name] = 'MasterItem'
		SELECT @ManufactureDate = CONVERT(datetime, @stepInput, 112)

		IF EXISTS(SELECT ID FROM MasterItem WHERE Code = @MasterItem)
		BEGIN
			SELECT @ShelfLife = ISNULL(ShelfLife, 0) 
			FROM MasterItem 
			WHERE Code = @MasterItem
		END
		ELSE IF EXISTS(SELECT ID FROM MasterItem WHERE FormattedCode = @MasterItem)
		BEGIN
			SELECT @ShelfLife = ISNULL(ShelfLife, 0) 
			FROM MasterItem 
			WHERE FormattedCode = @MasterItem
		END

		IF @ShelfLife > 0
		BEGIN
			SELECT @ExpiryDate = DATEADD(DAY, @ShelfLife, @ManufactureDate)

			INSERT INTO @Output
			SELECT 'ExpiryDate', CONVERT(VARCHAR(8), @ExpiryDate, 112)
		END

		SELECT @valid = 1
	END	
END






	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
