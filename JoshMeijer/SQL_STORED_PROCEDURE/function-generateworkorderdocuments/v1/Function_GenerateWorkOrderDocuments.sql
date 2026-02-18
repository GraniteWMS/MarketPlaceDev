CREATE PROCEDURE [dbo].[Function_GenerateWorkOrderDocuments] (
    @FunctionParameterInputs dbo.ScriptInputParameters READONLY,
    @RecordIdentities dbo.ScriptInputIdentities   READONLY   
)
AS

DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )

SET NOCOUNT ON;
	DECLARE @valid bit
	DECLARE @message varchar(MAX)
	SELECT @valid = 1                  
	
DECLARE @OutputItemNumber varchar(30) = (SELECT [Value] FROM @FunctionParameterInputs WHERE [Name] = 'OutputCode')
DECLARE @BomItemNumber varchar(30) = (SELECT TOP 1 ITEMNO FROM Custom_BomDetails WHERE MIXCODE = @OutputItemNumber)
DECLARE @LoopCount int = CAST((SELECT [Value] FROM @FunctionParameterInputs WHERE [Name] = 'LoopCount') AS int)
DECLARE @StartBarcode int = (SELECT ISNULL(NextBarcode, 0) FROM BarcodeMaster WHERE [Name] = 'DOCUMENTWORKORDER')

BEGIN TRY

	IF ISNULL(@OutputItemNumber, '') = ''
		RAISERROR('ERROR: An output item must be selected.', 16, 1)

	IF NOT EXISTS(SELECT 1 FROM MasterItem WHERE Code = @OutputItemNumber)
		RAISERROR('ERROR: Item "%s" does not exist.', 16, 1, @OutputItemNumber)

	--IF ISNUMERIC(@OutputItemQty) <> 1
	--	RAISERROR('ERROR: Qty is not valid.', 16, 1)

	--IF @OutputItemQty > 1000
	--	RAISERROR('ERROR: Qty exceeds the maximum qty allowed.', 16, 1)

	IF ISNULL(@LoopCount, '') = ''
		RAISERROR('ERROR: you must enter amount of boms', 16, 1)

	IF @LoopCount > 10
		RAISERROR('ERROR: The number of boms you have entered exceeds the limit of 10', 16, 1)

END TRY
BEGIN CATCH

	SELECT @valid = 0
	,@message = ERROR_MESSAGE()

END CATCH

IF @valid = 1
BEGIN
	
	DECLARE @valid1 bit, @valid2 bit
    DECLARE @message1 varchar(MAX), @message2 varchar(MAX)

	BEGIN TRY
		
		SELECT @valid1 = 1
		,@message1 = ''

		EXEC Utility_GenerateBomDocument
		@OutputItemNumber = @BomItemNumber
		,@LoopCount = @LoopCount
		,@StartBarcode = @StartBarcode
		,@valid = @valid1 OUTPUT
		,@message = @message1 OUTPUT

		SELECT @valid2 = 1
		,@message2 = ''

		EXEC Utility_GenerateMixDocument
		@OutputItemNumber = @OutputItemNumber
		,@LoopCount = @LoopCount
		,@StartBarcode = @StartBarcode
		,@valid = @valid2 OUTPUT
		,@message = @message2 OUTPUT

		UPDATE BarcodeMaster
		SET NextBarcode = @StartBarcode + @LoopCount
		WHERE [Name] = 'DOCUMENTWORKORDER'

		SELECT @valid = CASE WHEN @valid1 = 1 AND @valid2 = 1 THEN 1 ELSE 0 END
        ,@message = CONCAT(@message1, ' | ', @message2)

	END TRY
	BEGIN CATCH

		SELECT @valid = 0
		,@message = ERROR_MESSAGE()

	END CATCH
END

	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid

	SELECT * FROM @Output
