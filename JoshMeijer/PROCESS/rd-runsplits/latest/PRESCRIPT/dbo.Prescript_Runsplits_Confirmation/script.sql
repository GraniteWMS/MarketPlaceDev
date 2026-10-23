CREATE PROCEDURE [dbo].[Prescript_Runsplits_Confirmation] (
   @input dbo.ScriptInputParameters READONLY
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @process varchar(50) = 'RUNSPLITS'
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE @user varchar(30) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @LabelFormat varchar(50) = 'RECEIPTCONFIRMLIVE.BTW'
DECLARE @Printer varchar(50) = (SELECT Value FROM @input WHERE Name = 'PrinterName')
DECLARE @stepInput varchar(MAX) = (SELECT UPPER(Value) FROM @input WHERE Name = 'StepInput') 
DECLARE @DocumentNumber varchar(50) =(SELECT Value FROM @input WHERE Name = 'Filename') 
DECLARE @ErrorNumber int,           
        @ErrorSeverity int,          
        @ErrorState int          
DECLARE @FullFileName varchar(4000)
BEGIN TRY
    
    SET @Message      = NULL;
    SET @ErrorNumber  = NULL;
    SET @ErrorSeverity= NULL;
    SET @ErrorState   = NULL;
    IF LEFT(@stepInput,1) = 'Y'
    BEGIN
        SELECT @FullFileName = CONCAT('C:\Users\Administrator\Dropbox\ExcelTransfers\',@DocumentNumber,'.csv')
	    EXEC dbo.ImportAndCreateTransfers
        @MasterDocumentNumber = @DocumentNumber,
        @FromERPLocation      = 13,
        @filename             = @FullFileName
        
        SELECT @Valid = 1,
        @Message = 'Import Successful and File Archived';
    END
    ELSE
        SELECT @message = 'Did not confirm -Split and import cancelled'
END TRY
BEGIN CATCH
    
    SET @ErrorNumber   = ERROR_NUMBER();
    SET @ErrorSeverity = ERROR_SEVERITY();
    SET @ErrorState    = ERROR_STATE();
    SET @Message       = ERROR_MESSAGE();
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
