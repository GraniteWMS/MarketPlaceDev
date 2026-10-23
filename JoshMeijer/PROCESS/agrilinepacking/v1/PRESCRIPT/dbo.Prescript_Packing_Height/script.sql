CREATE PROCEDURE [dbo].[Prescript_Packing_Height] (
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
DECLARE @Location varchar(50) = (SELECT Value FROM @input WHERE Name = 'Location')
DECLARE @BoxNumber varchar(30) = (SELECT Value FROM @input WHERE Name = 'CarryingEntity')
DECLARE @Length varchar(30)
	SELECT @Length = Value FROM @input WHERE Name = 'Length'
DECLARE @Width varchar(30)
	SELECT @Width = Value FROM @input WHERE Name = 'Width'
DECLARE @Height varchar(30)
	SELECT @Height = Value FROM @input WHERE Name = 'Height'
DECLARE @LengthDecimal decimal(19,3)
DECLARE @WidthDecimal decimal(19,3)
DECLARE @HeightDecimal decimal(19,3)
BEGIN TRY
	
	IF @Length IS NOT NULL AND @Length <> ''
	BEGIN
		IF ISNUMERIC(@Length) = 0
		BEGIN
			SET @valid = 0
			SET @message = 'Length value cannot be converted to decimal(19,3): ' + @Length
			GOTO OutputResults
		END
		SET @LengthDecimal = CAST(@Length AS decimal(19,3))
	END
	
	IF @Width IS NOT NULL AND @Width <> ''
	BEGIN
		IF ISNUMERIC(@Width) = 0
		BEGIN
			SET @valid = 0
			SET @message = 'Width value cannot be converted to decimal(19,3): ' + @Width
			GOTO OutputResults
		END
		SET @WidthDecimal = CAST(@Width AS decimal(19,3))
	END
	
	IF @Height IS NOT NULL AND @Height <> ''
	BEGIN
		IF ISNUMERIC(@Height) = 0
		BEGIN
			SET @valid = 0
			SET @message = 'Height value cannot be converted to decimal(19,3): ' + @Height
			GOTO OutputResults
		END
		SET @HeightDecimal = CAST(@Height AS decimal(19,3))
	END
	UPDATE dbo.CarryingEntity
	SET [Length] = @LengthDecimal,
		[Width] = @WidthDecimal,
		[Height] = @HeightDecimal
	WHERE dbo.CarryingEntity.Barcode = @BoxNumber AND ISNULL(@LengthDecimal,0) > 0 AND ISNULL(@HeightDecimal,0) > 0 AND ISNULL(@WidthDecimal,0) > 0
END TRY
BEGIN CATCH
	SELECT @valid = 0
	,@message = ERROR_MESSAGE()
END CATCH
OutputResults:
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT Name, Value FROM @Output
