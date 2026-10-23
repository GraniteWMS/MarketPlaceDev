CREATE PROCEDURE [dbo].[PrescriptAddEANBarcodeMasterItem] (
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
DECLARE   @MasterItemID   bigint       = NULL
        , @MasterItemCode varchar(50)   = NULL
        , @MasterItemCnt  int          = 0;
BEGIN TRY
    SELECT 
        @stepInput = LTRIM(RTRIM([Value]))
    FROM @input
    WHERE [Name] = 'StepInput';
    IF ISNULL(@stepInput, '') = ''
    BEGIN
        SET @valid = 0;
        SET @message = 'Please enter a MasterItem code';
    END
    ELSE
    BEGIN
        SELECT 
            @MasterItemCnt = COUNT(1)
        FROM dbo.MasterItem WITH (NOLOCK)
        WHERE Code = @stepInput;
        IF @MasterItemCnt = 0
        BEGIN
            SET @valid = 0;
            SET @message = 'Please enter a valid MasterItem';
        END
        ELSE IF @MasterItemCnt > 1
        BEGIN
            SET @valid = 0;
            SET @message = 'Duplicate MasterItem codes found. Please contact your administrator.';
        END
        ELSE
        BEGIN
            SELECT 
                    @MasterItemID   = ID
                , @MasterItemCode = Code
            FROM dbo.MasterItem WITH (NOLOCK)
            WHERE Code = @stepInput;
            SET @valid = 1;
            SET @message = '';
            SET @stepInput = @MasterItemCode;
        END
    END
END TRY
BEGIN CATCH
    SET @valid = 0;
    SET @message = 'Error: ' + ERROR_MESSAGE();
END CATCH;
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
