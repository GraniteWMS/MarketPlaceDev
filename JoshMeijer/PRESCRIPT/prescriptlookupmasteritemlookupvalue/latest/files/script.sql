CREATE   PROCEDURE dbo.PrescriptLookupMasterItemLookUpValue
    @input dbo.ScriptInputParameters READONLY
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Output TABLE (Name varchar(max), Value varchar(max));
    DECLARE @valid     int           = 1;
    DECLARE @message   varchar(200)  = '';
    DECLARE @stepInput varchar(max)  = (SELECT TOP 1 Value FROM @input WHERE Name = 'StepInput');
    DECLARE @userName  varchar(40)   = (SELECT TOP 1 Value FROM @input WHERE Name = 'User');
    DECLARE @type      varchar(40)   = (SELECT TOP 1 Value FROM @input WHERE Name = 'Type');
    SET @stepInput = LTRIM(RTRIM(ISNULL(@stepInput, '')));
    BEGIN TRY
        IF @stepInput = ''
            RAISERROR('Scan or enter a value.', 16, 1);
        IF @type IS NULL OR LTRIM(RTRIM(@type)) = ''
            RAISERROR('Lookup type not set.', 16, 1);
        IF @type = 'MasterItem'
        BEGIN
            IF NOT EXISTS (
                SELECT 1
                FROM dbo.MasterItem MI WITH (NOLOCK)
                WHERE MI.Code = @stepInput
                   OR MI.FormattedCode = @stepInput
            )
            AND NOT EXISTS (
                SELECT 1
                FROM dbo.MasterItemAlias_View MIA WITH (NOLOCK)
                WHERE MIA.Code = @stepInput
            )
                RAISERROR('Invalid item code.', 16, 1);
        END
        ELSE IF @type = 'Inventory'
        BEGIN
            IF NOT EXISTS (
                SELECT 1
                FROM dbo.TrackingEntity TE WITH (NOLOCK)
                WHERE TE.Barcode = @stepInput
            )
                RAISERROR('Invalid tracking barcode.', 16, 1);
        END
        ELSE IF @type = 'Location'
        BEGIN
            IF NOT EXISTS (
                SELECT 1
                FROM dbo.Location L WITH (NOLOCK)
                WHERE L.Barcode = @stepInput
            )
                RAISERROR('Invalid location barcode.', 16, 1);
        END
        ELSE IF @type = 'Serial'
        BEGIN
            IF NOT EXISTS (
                SELECT 1
                FROM dbo.TrackingEntity TE WITH (NOLOCK)
                WHERE TE.SerialNumber = @stepInput
            )
                RAISERROR('Serial number not found.', 16, 1);
        END
        ELSE IF @type = 'Batch'
        BEGIN
            IF NOT EXISTS (
                SELECT 1
                FROM dbo.TrackingEntity TE WITH (NOLOCK)
                WHERE TE.Batch = @stepInput
            )
                RAISERROR('Batch number not found.', 16, 1);
        END
        ELSE
        BEGIN
            RAISERROR('Unknown lookup type.', 16, 1);
        END
    END TRY
    BEGIN CATCH
        SET @valid   = 0;
        SET @message = ERROR_MESSAGE();
    END CATCH;
    IF @valid = 1
        INSERT INTO @Output (Name, Value) VALUES ('LookupValue', @stepInput);
    INSERT INTO @Output (Name, Value) VALUES ('Message',   @message);
    INSERT INTO @Output (Name, Value) VALUES ('Valid',     CONVERT(varchar(10), @valid));
    INSERT INTO @Output (Name, Value) VALUES ('StepInput', @stepInput);
    SELECT Name, Value FROM @Output;
END
