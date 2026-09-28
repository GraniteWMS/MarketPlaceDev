CREATE PROCEDURE  [dbo].[WebDesktopFunction_GenerateStockOnHandFile] (
    @FunctionParameterInputs dbo.ScriptInputParameters READONLY,
    @RecordIdentities dbo.ScriptInputIdentities   READONLY   
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE 
      @tableName          VARCHAR(100)
    , @offset             INT
    , @limit              INT
    , @fileDestinationPath VARCHAR(MAX)
    , @fileType           VARCHAR(20)
    , @orderByList        VARCHAR(MAX)
    , @filters            VARCHAR(MAX)
    , @success            BIT
    , @Mode               VARCHAR(20)
    , @SessionName        VARCHAR(50)
    , @Warehouse          VARCHAR(50)
    , @fileFolder         VARCHAR(MAX)
    , @fileName           VARCHAR(MAX);
SELECT @fileFolder  = 'C:\GraniteExports';
SELECT @fileType    = 'csv';
IF ISNULL(@fileFolder,'') = ''
BEGIN
    RAISERROR('FilePath is required.', 16, 1);  
END
IF RIGHT(@fileFolder,1) NOT IN ('\','/')
    SET @fileFolder = @fileFolder + '\';
IF ISNULL(@fileType,'') = ''
    SET @fileType = 'csv';
SET @fileName = 
    'StockExport_' +
    REPLACE(CONVERT(VARCHAR(19),GETDATE(),120),':','-') +
    '.' + @fileType;
SET @fileDestinationPath = @fileFolder + @fileName;
SET @orderByList = '';
SET @filters     = '';
SET @offset      = 0;
SET @limit       = 2000000;
SET @tableName = 'Custom_Report_Stock_All';
BEGIN TRY
    EXEC dbo.clr_TableExport
            @tableName,
            @filters,
            @offset,
            @limit,
            @orderByList,
            @fileDestinationPath,
            @fileType,
            @success OUTPUT,
            @message OUTPUT;
END TRY
BEGIN CATCH
    SET @success = 0;
    SET @message = ERROR_MESSAGE();
END CATCH
DECLARE @templateParameters NVARCHAR(MAX) = NULL;
DECLARE @subject nvarchar(max)
DECLARE @templateName nvarchar(max)
DECLARE @toEmailAddresses nvarchar(max)
DECLARE @ccEmailAddresses nvarchar(max)
DECLARE @bccEmailAddresses nvarchar(max)
DECLARE @reportAttachments nvarchar(max)
DECLARE @excelAttachments nvarchar(max)
DECLARE @fileAttachments nvarchar(max)
BEGIN TRY
    SET @subject = 'Granite Stocktake Import File';
    SET @toEmailAddresses = ''
    SET @ccEmailAddresses = NULL;
    SET @bccEmailAddresses = NULL;
	SET @fileAttachments = dbo.email_AddFileAttachment(@fileAttachments, CONCAT(@fileFolder, @fileName))        
    EXECUTE [dbo].[clr_SimpleEmail] 
   @subject
  ,NULL
  ,@toEmailAddresses
  ,@ccEmailAddresses
  ,@bccEmailAddresses
  ,@reportAttachments
  ,@excelAttachments
  ,@fileAttachments
  ,@success OUTPUT
  ,@message OUTPUT
END TRY
BEGIN CATCH
    SELECT @message = ERROR_MESSAGE();
    SET @success = 0;
END CATCH;
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
SELECT * FROM @Output