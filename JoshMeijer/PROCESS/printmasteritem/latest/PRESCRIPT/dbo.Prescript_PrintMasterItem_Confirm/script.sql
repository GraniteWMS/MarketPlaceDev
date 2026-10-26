CREATE   PROCEDURE [dbo].[Prescript_PrintMasterItem_Confirm]
(
    @input dbo.ScriptInputParameters READONLY
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Output TABLE
    (
        Name  varchar(max),
        Value varchar(max)
    );
    DECLARE @valid bit = 1;
    DECLARE @message varchar(MAX) = '';
    DECLARE @UserName      varchar(50)  = (SELECT Value FROM @input WHERE Name = 'User');
    DECLARE @StepInput     varchar(MAX) = (SELECT Value FROM @input WHERE Name = 'StepInput');
    DECLARE @MasterItem      varchar(50)  = (SELECT Value FROM @input WHERE Name = 'MasterItem');
    DECLARE @Labelformat      varchar(50)  = (SELECT Value FROM @input WHERE Name = 'LabelFormat');
    DECLARE @PrinterName   nvarchar(50) = (SELECT UPPER(Value) FROM @input WHERE Name = 'PrinterName');
    DECLARE @UserID        bigint       = (SELECT ID FROM dbo.Users WHERE Name = @UserName);
    DECLARE @Barcode       nvarchar(50);
    DECLARE @Barcodes      nvarchar(4000) = NULL;
    DECLARE @LabelName     nvarchar(500) = (SELECT Value FROM @input WHERE Name = 'LabelFormat');
    DECLARE @NumberOfLabels int = CONVERT(int,(SELECT Value FROM @input WHERE Name = 'Qty'));
    DECLARE @Type          nvarchar(50) = 'MASTERITEM';
    DECLARE @Success       bit;
    DECLARE @LinesPrinted  int = 0;
    DECLARE @RowID         int = 1;
    DECLARE @MaxRowID      int;
    BEGIN TRY
        IF ISNULL(LTRIM(RTRIM(@StepInput)), '') NOT IN ('Y', 'YES', 'Yes', 'yes')
            RAISERROR('Not confirmed - no action taken', 16, 1);
  
        IF ISNULL(LTRIM(RTRIM(@PrinterName)), '') = ''
            RAISERROR('PrinterName not supplied', 16, 1);
        IF @UserID IS NULL
            RAISERROR('User not found: %s', 16, 1, @UserName);
		SELECT @Barcode = @MasterItem
        IF @Barcode IS NOT NULL AND ISNULL(@NumberOfLabels, 0) > 0
        BEGIN
                SET @Success = 0;
                SET @message = '';
                EXEC dbo.clr_PrintLabel
                     @Barcode,
                     @Barcodes,
                     @LabelName,
                     @NumberOfLabels,
                     @PrinterName,
                     @Type,
                     @UserID,
                     @Success OUTPUT,
                     @message OUTPUT;
				 IF ISNULL(@Success, 0) = 0
				BEGIN
					DECLARE @PrintMessage varchar(MAX);
					SET @PrintMessage = ISNULL(@message, '');
					RAISERROR('Print failed for ItemCode %s. Message: %s', 16, 1, @Barcode, @PrintMessage);
				END
		END
        SET @valid = 1;
        SET @message = 'Labels printed'
    END TRY
    BEGIN CATCH
        SET @valid = 0;
        SET @message = ERROR_MESSAGE();
    END CATCH;
    INSERT INTO @Output
    SELECT 'Message', @message;
    INSERT INTO @Output
    SELECT 'Valid', CONVERT(varchar(10), @valid);
    INSERT INTO @Output
    SELECT 'StepInput', ISNULL(@StepInput, '');
    SELECT *
    FROM @Output;
END
