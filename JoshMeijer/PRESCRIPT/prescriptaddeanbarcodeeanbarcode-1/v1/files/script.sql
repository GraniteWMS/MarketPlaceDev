CREATE PROCEDURE [dbo].[PrescriptAddEANBarcodeEANBarcode] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 0
DECLARE @message varchar(MAX) = 'Could not capture barcode'
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE   @AliasBarcode           varchar(50)
        , @MasterItemInput        varchar(50)
        , @MasterItemIDText       varchar(50)
        , @MasterItemIDInput      bigint
        , @MasterItemID           bigint
        , @MasterItemCode         varchar(50)
        , @ExistingMasterItemID   bigint
        , @ExistingMasterItemCode varchar(50)
        , @BarcodeLength          int
        , @MasterItemCount        int;
BEGIN TRY
    
    SELECT 
        @stepInput = LTRIM(RTRIM([Value]))
    FROM @input 
    WHERE [Name] = 'StepInput';
    SET @AliasBarcode = LTRIM(RTRIM(ISNULL(@stepInput, '')));
    
    SELECT 
        @MasterItemInput = LTRIM(RTRIM([Value]))
    FROM @input
    WHERE [Name] = 'MasterItem';
    IF ISNULL(@MasterItemInput, '') = ''
    BEGIN
        SELECT 
            @MasterItemInput = LTRIM(RTRIM([Value]))
        FROM @input
        WHERE [Name] = 'MasterItemCode';
    END;
    SELECT 
        @MasterItemIDText = LTRIM(RTRIM([Value]))
    FROM @input
    WHERE [Name] = 'MasterItemID';
    IF ISNULL(@MasterItemIDText, '') <> ''
        AND @MasterItemIDText NOT LIKE '%[^0-9]%'
    BEGIN
        SET @MasterItemIDInput = CAST(@MasterItemIDText AS bigint);
    END;
    SET @BarcodeLength = LEN(@AliasBarcode);
    
    IF ISNULL(@AliasBarcode, '') = ''
    BEGIN
        SET @valid = 0;
        SET @message = 'Please scan or enter a barcode.';
    END
    
    ELSE IF @AliasBarcode LIKE '%[^0-9]%'
    BEGIN
        SET @valid = 0;
        SET @message = 'Invalid barcode. The barcode may only contain numbers. Scanned value: ' 
                        + @AliasBarcode 
                        + '.';
    END
    
    ELSE IF @BarcodeLength NOT IN (8, 12, 13, 14)
    BEGIN
        SET @valid = 0;
        SET @message = 'Invalid barcode length. Valid barcode lengths are 8, 12, 13, or 14 digits. Current length: ' 
                        + CAST(@BarcodeLength AS varchar(10)) 
                        + '. Barcode: ' 
                        + @AliasBarcode 
                        + '.';
    END
    ELSE
    BEGIN
        
        IF @MasterItemIDInput IS NOT NULL
        BEGIN
            SELECT TOP (1)
                    @MasterItemID = MI.ID
                , @MasterItemCode = MI.Code
            FROM dbo.MasterItem MI WITH (NOLOCK)
            WHERE MI.ID = @MasterItemIDInput;
        END;
        
        IF @MasterItemID IS NULL AND ISNULL(@MasterItemInput, '') <> ''
        BEGIN
            SELECT 
                @MasterItemCount = COUNT(1)
            FROM dbo.MasterItem MI WITH (NOLOCK)
            WHERE MI.Code = @MasterItemInput;
            IF @MasterItemCount > 1
            BEGIN
                SET @valid = 0;
                SET @message = 'Duplicate MasterItem codes found for ' 
                                + @MasterItemInput 
                                + '. Please contact your administrator.';
            END
            ELSE IF @MasterItemCount = 1
            BEGIN
                SELECT TOP (1)
                        @MasterItemID = MI.ID
                    , @MasterItemCode = MI.Code
                FROM dbo.MasterItem MI WITH (NOLOCK)
                WHERE MI.Code = @MasterItemInput;
            END
        END;
        IF @MasterItemID IS NULL AND @message NOT LIKE 'Duplicate MasterItem codes found%'
        BEGIN
            SET @valid = 0;
            SET @message = 'Please enter or select a valid MasterItem before scanning the barcode.';
        END
        ELSE IF @MasterItemID IS NOT NULL
        BEGIN
            
            SELECT TOP (1)
                    @ExistingMasterItemID = MIA.MasterItem_id
                , @ExistingMasterItemCode = MI.Code
            FROM dbo.MasterItemAlias MIA WITH (NOLOCK)
            LEFT JOIN dbo.MasterItem MI WITH (NOLOCK)
                ON MI.ID = MIA.MasterItem_id
            WHERE MIA.Code = @AliasBarcode;
            IF @ExistingMasterItemID IS NOT NULL
            BEGIN
                IF @ExistingMasterItemID = @MasterItemID
                BEGIN
                    SET @valid = 0;
                    SET @message = 'This barcode is already linked to this MasterItem. Barcode: ' 
                                    + @AliasBarcode 
                                    + '. MasterItem: ' 
                                    + ISNULL(@MasterItemCode, '(unknown)') 
                                    + '.';
                END
                ELSE
                BEGIN
                    SET @valid = 0;
                    SET @message = 'This barcode is already linked to stock code ' 
                                    + ISNULL(@ExistingMasterItemCode, '(unknown)') 
                                    + '. Barcode: ' 
                                    + @AliasBarcode 
                                    + '.';
                END
            END
            ELSE
            BEGIN
                SET @valid = 1;
                SET @message = 'You are about to link barcode ' 
                                + @AliasBarcode 
                                + ' to MasterItem ' 
                                + ISNULL(@MasterItemCode, @MasterItemInput) 
                                + '. Please press YES to confirm.';
            END
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
