CREATE PROCEDURE [dbo].[PrescriptUpdateExpiryDateExpiryDate] 
(
   @input dbo.ScriptInputParameters READONLY
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Output TABLE
    (
        Name varchar(max),
        Value varchar(max)
    );
    DECLARE @valid bit = 1;
    DECLARE @message varchar(MAX) = '';
    DECLARE @stepInput varchar(MAX);
    SELECT @stepInput = Value 
    FROM @input 
    WHERE Name = 'StepInput';
    DECLARE @trackingEntityId bigint;
    DECLARE @trackingEntity varchar(50);
    DECLARE @Comment varchar(50);
    DECLARE @FromExpiry date;
    DECLARE @ToExpiry date;
    DECLARE @User varchar(50);
    SELECT @trackingEntity = Value FROM @input WHERE Name = 'TrackingEntity';
    SELECT @Comment = Value FROM @input WHERE Name = 'Comment';
    SELECT @User = Value FROM @input WHERE Name = 'User';
    SELECT 
        @FromExpiry = ExpiryDate,
        @trackingEntityId = ID
    FROM dbo.TrackingEntity
    WHERE Barcode = @trackingEntity;
    IF ISNULL(@trackingEntity, '') = ''
    BEGIN
        SELECT @valid = 0;
        SELECT @message = 'Tracking Entity cannot be blank';
        GOTO EndScript;
    END;
    IF @trackingEntityId IS NULL
    BEGIN
        SELECT @valid = 0;
        SELECT @message = 'Tracking Entity not found: ' + ISNULL(@trackingEntity, '');
        GOTO EndScript;
    END;
    
    IF LEN(@stepInput) = 8
       AND @stepInput NOT LIKE '%[^0-9]%'
       AND TRY_CONVERT(date, @stepInput, 112) IS NOT NULL
    BEGIN
        SELECT @ToExpiry = TRY_CONVERT(date, @stepInput, 112);
        IF YEAR(@ToExpiry) <= 2018
        BEGIN
            SELECT @valid = 0;
            SELECT @message = 'Year must be greater than 2018. Please use format YYYYMMDD.';
            GOTO EndScript;
        END;
        UPDATE dbo.TrackingEntity
        SET 
            ExpiryDate = @ToExpiry
        WHERE ID = @trackingEntityId;
        INSERT INTO dbo.Audit
        (
            AuditDate,
            AuditTime,
            [User],
            RecordID,
            RecordVersion,
            [Application],
            TableName,
            ChangeType,
            ColumnName,
            PreviousValue,
            NewValue
        )
        VALUES
        (
            CONVERT(date, GETDATE()),
            CONVERT(time, GETDATE()),
            LEFT(ISNULL(@User, 'INTEGRATION'), 20),
            @trackingEntityId,
            NULL,
            'Granite Scanner',
            'TrackingEntity',
            'UPDATE',
            'ExpiryDate',
            CONVERT(varchar(10), @FromExpiry, 120),
            CONVERT(varchar(10), @ToExpiry, 120)
        );
        SELECT @valid = 1;
        SELECT @message = 'Expiry has been updated to: ' 
                        + CONVERT(varchar(8), @ToExpiry, 112) 
                        + ' on Barcode ' + @trackingEntity;
    END
    ELSE
    BEGIN
        SELECT @valid = 0;
        SELECT @message = 'Please use format YYYYMMDD. Example: 20260520';
    END;
    EndScript:
    INSERT INTO @Output SELECT 'Message', @message;
    INSERT INTO @Output SELECT 'Valid', @valid;
    INSERT INTO @Output SELECT 'StepInput', @stepInput;
    SELECT * FROM @Output;
END
