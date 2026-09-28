CREATE PROCEDURE [dbo].[PrescriptUpdateBatchTrackingEntity] 
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
    DECLARE @trackingEntity varchar(50);
	DECLARE @trackingEntityId bigint;
    SELECT @trackingEntity = @stepInput;
	SELECT @trackingEntityId = ID 
	FROM TrackingEntity
	WHERE Barcode = @trackingEntity
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
    EndScript:
    INSERT INTO @Output SELECT 'Message', @message;
    INSERT INTO @Output SELECT 'Valid', @valid;
    INSERT INTO @Output SELECT 'StepInput', @stepInput;
    SELECT * FROM @Output;
END
