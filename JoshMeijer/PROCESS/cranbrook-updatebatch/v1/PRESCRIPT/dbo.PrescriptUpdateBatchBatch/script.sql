CREATE PROCEDURE [dbo].[PrescriptUpdateBatchBatch] 
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
    SELECT @stepInput = LTRIM(RTRIM(Value)) 
    FROM @input 
    WHERE Name = 'StepInput';
    DECLARE @trackingEntity varchar(50);
    DECLARE @trackingEntityId bigint;
    DECLARE @oldBatch varchar(max);
    DECLARE @newBatch varchar(max);
    DECLARE @User varchar(50);
    SELECT @trackingEntity = LTRIM(RTRIM(Value)) FROM @input WHERE Name = 'TrackingEntity';
    SELECT @User = Value FROM @input WHERE Name = 'User';
    SET @newBatch = @stepInput;
    IF ISNULL(@trackingEntity, '') = ''
    BEGIN
        SELECT @valid = 0;
        SELECT @message = 'Tracking Entity cannot be blank';
        GOTO EndScript;
    END;
    IF ISNULL(@newBatch, '') = ''
    BEGIN
        SELECT @valid = 0;
        SELECT @message = 'Batch cannot be blank';
        GOTO EndScript;
    END;
    SELECT 
        @trackingEntityId = ID,
        @oldBatch = Batch
    FROM dbo.TrackingEntity
    WHERE Barcode = @trackingEntity;
    IF @trackingEntityId IS NULL
    BEGIN
        SELECT @valid = 0;
        SELECT @message = 'Tracking Entity not found: ' + @trackingEntity;
        GOTO EndScript;
    END;
    IF ISNULL(@oldBatch, '') = ISNULL(@newBatch, '')
    BEGIN
        SELECT @valid = 1;
        SELECT @message = 'Batch is already set to: ' + @newBatch + ' on Barcode ' + @trackingEntity;
        GOTO EndScript;
    END;
    UPDATE dbo.TrackingEntity
    SET 
        Batch = @newBatch
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
        'Batch',
        ISNULL(@oldBatch, ''),
        @newBatch
    );
    SELECT @valid = 1;
    SELECT @message = 'Batch has been updated to: ' + @newBatch + ' on Barcode ' + @trackingEntity;
    EndScript:
    INSERT INTO @Output SELECT 'Message', @message;
    INSERT INTO @Output SELECT 'Valid', @valid;
    INSERT INTO @Output SELECT 'StepInput', @stepInput;
    SELECT * FROM @Output;
END
