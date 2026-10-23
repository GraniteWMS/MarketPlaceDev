CREATE   PROCEDURE [dbo].[Prescript_TransferReplenPick_Document] (
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
DECLARE @Zone VARCHAR(30) = LTRIM(RTRIM(@stepInput))
DECLARE @DocumentNumber VARCHAR(30)
DECLARE @LineCount INT
DECLARE @WasExisting BIT
BEGIN TRY
    IF @Zone IS NULL OR @Zone = ''
        RAISERROR('No zone was provided.', 16, 1)
    EXEC dbo.Utility_CreateReplenishmentTransfers
        @Zone = @Zone,
        @DocumentNumber = @DocumentNumber OUTPUT,
        @LineCount = @LineCount OUTPUT,
        @WasExisting = @WasExisting OUTPUT
    IF @DocumentNumber IS NOT NULL AND @WasExisting = 1
        SELECT @message = 'Continuing with zone ' + @Zone + ' (' + CAST(@LineCount AS VARCHAR(10)) + ' line(s)).'
    ELSE IF @DocumentNumber IS NOT NULL
        SELECT @message = 'Created worklist ' + @DocumentNumber + ' with ' + CAST(@LineCount AS VARCHAR(10)) + ' line(s).'
    ELSE
        RAISERROR('No items currently need replenishment in zone %s.', 16, 1, @Zone)
    SELECT @valid = 1
    ,@stepInput = @DocumentNumber
END TRY
BEGIN CATCH
    SELECT @valid = 0
    ,@message = ERROR_MESSAGE()
END CATCH
    INSERT INTO @Output
    SELECT 'Message', @message
    INSERT INTO @Output
    SELECT 'Valid', @valid
    INSERT INTO @Output
    SELECT 'StepInput', @stepInput
    SELECT * FROM @Output
