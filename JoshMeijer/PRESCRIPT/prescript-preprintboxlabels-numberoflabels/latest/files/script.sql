CREATE PROCEDURE [dbo].[Prescript_PREPRINTBOXLABELS_NumberOfLabels] (
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
DECLARE @Printer varchar(50) = (SELECT Value FROM @input WHERE Name = 'PrinterName'),
@User varchar(50) = (SELECT Value FROM @input WHERE Name = 'User'),
@NumberOfLabels int = TRY_CONVERT(INT, @stepInput)
      BEGIN TRY
            
            IF ISNULL(@Printer, '') = ''
                  RAISERROR('You must enter a printer name', 16, 1)
            IF ISNULL(@NumberOfLabels, 0) = 0
                  RAISERROR(N'%s is not a valid input', 16, 1, @stepInput)
            IF @NumberOfLabels >100
                  RAISERROR('You cannot print more than 100 pallet labels at a time.  You entered:%s', 16, 1, @stepInput)
            EXEC Utility_GenerateBoxLabelsAndInsertIntoQueue @NumberOfLabels, @User, @Printer
            
            SELECT
            @valid = 1,
            @message = CONCAT(CONVERT(varchar(10),@NumberOfLabels), ' labels inserted into queue')
      END TRY
      BEGIN CATCH
            SELECT
            @valid = 0,
            @message = ERROR_MESSAGE()
      END CATCH
      INSERT INTO @Output
      SELECT 'Message', @message
      INSERT INTO @Output
      SELECT 'Valid', @valid
      INSERT INTO @Output
      SELECT 'StepInput', @stepInput
      SELECT * FROM @Output
