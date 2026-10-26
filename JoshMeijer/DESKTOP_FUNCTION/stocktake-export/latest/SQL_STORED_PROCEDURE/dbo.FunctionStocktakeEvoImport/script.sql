CREATE PROCEDURE [dbo].[FunctionStocktakeEvoImport]
(
    @FunctionParameterInputs dbo.ScriptInputParameters READONLY,
    @RecordIdentities dbo.ScriptInputIdentities READONLY
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Output TABLE
    (
          Name  VARCHAR(MAX)
        , Value VARCHAR(MAX)
    );
    DECLARE
          @valid               BIT = 1
        , @message             VARCHAR(MAX) = ''
        , @tableName           VARCHAR(100)
        , @offset              INT = 0
        , @limit               INT = 2000000
        , @fileDestinationPath VARCHAR(MAX)
        , @fileType            VARCHAR(20) = 'csv'
        , @orderByList         VARCHAR(MAX) = ''
        , @filters             VARCHAR(MAX) = ''
        , @success             BIT = 0
        , @Mode                VARCHAR(20)
        , @SessionName         VARCHAR(50)
        , @Warehouse           VARCHAR(50)
        , @fileFolder          VARCHAR(MAX)
        , @fileName            VARCHAR(MAX);
    DECLARE
          @templateParameters  NVARCHAR(MAX) = NULL
        , @subject             NVARCHAR(MAX)
        , @templateName        NVARCHAR(MAX)
        , @toEmailAddresses    NVARCHAR(MAX)
        , @ccEmailAddresses    NVARCHAR(MAX)
        , @bccEmailAddresses   NVARCHAR(MAX)
        , @reportAttachments   NVARCHAR(MAX)
        , @excelAttachments    NVARCHAR(MAX)
        , @fileAttachments     NVARCHAR(MAX);
    SELECT @Mode = [Value]
    FROM @FunctionParameterInputs
    WHERE [Name] = 'MODE';
    SELECT @SessionName = [Value]
    FROM @FunctionParameterInputs
    WHERE [Name] = 'SESSION';
    SELECT @Warehouse = [Value]
    FROM @FunctionParameterInputs
    WHERE [Name] = 'LOCATION';
    SELECT @fileFolder = CAST([Value] AS VARCHAR(MAX))
    FROM dbo.SystemSettings
    WHERE [Application] = 'Granite.Function.StocktakeExport.Export'
      AND [Key] = 'Folder'
      AND [isActive] = 1;
    SELECT @toEmailAddresses = CAST([Value] AS NVARCHAR(MAX))
    FROM dbo.SystemSettings
    WHERE [Application] = 'Granite.Function.StocktakeExport.Email'
      AND [Key] = 'To'
      AND [isActive] = 1;
    SELECT @ccEmailAddresses = CAST([Value] AS NVARCHAR(MAX))
    FROM dbo.SystemSettings
    WHERE [Application] = 'Granite.Function.StocktakeExport.Email'
      AND [Key] = 'Cc'
      AND [isActive] = 1;
    SELECT @bccEmailAddresses = CAST([Value] AS NVARCHAR(MAX))
    FROM dbo.SystemSettings
    WHERE [Application] = 'Granite.Function.StocktakeExport.Email'
      AND [Key] = 'Bcc'
      AND [isActive] = 1;
    IF ISNULL(@Mode, '') = ''
    BEGIN
        SET @valid = 0;
        SET @success = 0;
        SET @message = 'Mode is required: ALL, WAREHOUSE, SESSION, SESSION_WH';
        GOTO EndFunction;
    END
    IF ISNULL(@fileFolder, '') = ''
    BEGIN
        SET @valid = 0;
        SET @success = 0;
        SET @message = 'System setting Granite.Function.StocktakeExport.Export / Folder is required.';
        GOTO EndFunction;
    END
    IF ISNULL(@toEmailAddresses, '') = ''
    BEGIN
        SET @valid = 0;
        SET @success = 0;
        SET @message = 'System setting Granite.Function.StocktakeExport.Email / To is required.';
        GOTO EndFunction;
    END
    IF RIGHT(@fileFolder, 1) NOT IN ('\', '/')
        SET @fileFolder = @fileFolder + '\';
    SET @fileName =
        'StockExport_' +
        REPLACE(CONVERT(VARCHAR(19), GETDATE(), 120), ':', '-') +
        '.' + @fileType;
    SET @fileDestinationPath = @fileFolder + @fileName;
    IF @Mode = 'ALL'
    BEGIN
        SET @tableName = 'Custom_Report_Stock_All';
    END
    ELSE IF @Mode = 'WAREHOUSE'
    BEGIN
        IF ISNULL(@Warehouse, '') = ''
        BEGIN
            SET @valid = 0;
            SET @success = 0;
            SET @message = 'Warehouse is required for WAREHOUSE mode.';
            GOTO EndFunction;
        END
        SET @tableName = 'Custom_Stock_All_Warehouse';
        SET @filters = dbo.export_AddFilter(@filters, 'LOCATION', 'Equal', @Warehouse);
    END
    ELSE IF @Mode = 'SESSION'
    BEGIN
        IF ISNULL(@SessionName, '') = ''
        BEGIN
            SET @valid = 0;
            SET @success = 0;
            SET @message = 'SessionName is required for SESSION mode.';
            GOTO EndFunction;
        END
        SET @tableName = 'Custom_Stock_All_Session';
        SET @filters = dbo.export_AddFilter(@filters, 'SessionName', 'Equal', @SessionName);
    END
    ELSE IF @Mode = 'SESSION_WH'
    BEGIN
        IF ISNULL(@SessionName, '') = '' OR ISNULL(@Warehouse, '') = ''
        BEGIN
            SET @valid = 0;
            SET @success = 0;
            SET @message = 'Both SessionName and Warehouse are required for SESSION_WH.';
            GOTO EndFunction;
        END
        SET @tableName = 'Custom_Stock_All_Session';
        SET @filters = dbo.export_AddFilter(@filters, 'SessionName', 'Equal', @SessionName);
        SET @filters = dbo.export_AddFilter(@filters, 'LOCATION', 'Equal', @Warehouse);
    END
    ELSE
    BEGIN
        SET @valid = 0;
        SET @success = 0;
        SET @message = 'Invalid Mode. Options: ALL, WAREHOUSE, SESSION, SESSION_WH';
        GOTO EndFunction;
    END
    BEGIN TRY
        EXEC dbo.clr_TableExport
              @tableName
            , @filters
            , @offset
            , @limit
            , @orderByList
            , @fileDestinationPath
            , @fileType
            , @success OUTPUT
            , @message OUTPUT;
    END TRY
    BEGIN CATCH
        SET @success = 0;
        SET @valid = 0;
        SET @message = ERROR_MESSAGE();
    END CATCH
    IF ISNULL(@success, 0) = 1
    BEGIN
        BEGIN TRY
            SET @subject = 'Granite Stocktake Import File';
            SET @templateName = 'StocktakeExport';
            SET @reportAttachments = NULL;
            SET @excelAttachments = NULL;
            SET @fileAttachments = NULL;
            SET @fileAttachments = dbo.email_AddFileAttachment(@fileAttachments, @fileDestinationPath);
            EXEC dbo.clr_TemplateEmail
                  @subject
                , @templateName
                , @templateParameters
                , @toEmailAddresses
                , @ccEmailAddresses
                , @bccEmailAddresses
                , @reportAttachments
                , @excelAttachments
                , @fileAttachments
                , @success OUTPUT
                , @message OUTPUT;
        END TRY
        BEGIN CATCH
            SET @success = 0;
            SET @valid = 0;
            SET @message = ERROR_MESSAGE();
        END CATCH
    END
    ELSE
    BEGIN
        SET @valid = 0;
    END
EndFunction:
    INSERT INTO @Output
    SELECT 'Message', ISNULL(@message, '');
    INSERT INTO @Output
    SELECT 'Valid', CAST(ISNULL(@valid, 0) AS VARCHAR(10));
    SELECT *
    FROM @Output;
END
