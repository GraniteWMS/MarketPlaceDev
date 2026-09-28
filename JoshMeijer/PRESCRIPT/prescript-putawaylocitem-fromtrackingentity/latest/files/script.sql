CREATE PROCEDURE [dbo].[Prescript_PutawayLocItem_ToTrackingEntity] (
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
DECLARE @userName nvarchar(max) = (SELECT Value FROM @input WHERE Name = 'User')
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @FromTrackingEntityBarcode varchar(50) 
DECLARE @FromLocationBarcode varchar(50) = (SELECT TRIM(Value) FROM @input WHERE Name = 'FromLocation')
DECLARE @MasterItemCode varchar (40)
DECLARE @MasterItem_id bigint
BEGIN TRY
 
    IF EXISTS (SELECT 1 FROM dbo.MasterItem WHERE Code = @stepInput AND isActive = 1)
        SET @MasterItemCode = @stepInput;
    ELSE
    BEGIN
        IF LEN(@stepInput) = 13 AND EXISTS(SELECT 1 FROM dbo.MasterItem WHERE Code = LEFT(@stepInput,12))
        BEGIN
            SET @MasterItemCode = LEFT(@stepInput,12)
            SELECT @stepInput = LEFT(@stepInput,12)
        END
        ELSE
        BEGIN
            DECLARE @aliasCount int = 0, @aliasCode varchar(100) = NULL;
            SELECT @aliasCount = COUNT(*),
                    @aliasCode  = MAX(MI.Code)
            FROM MasterItemAlias_View MIAV
            JOIN dbo.MasterItem      MI ON MIAV.MasterItem_id = MI.ID
            WHERE MIAV.Code = @stepInput 
                AND MI.isActive = 1;
            IF @aliasCount = 0
                RAISERROR('(%s) is not a valid item code or known alias.', 16, 1, @stepInput);
            IF @aliasCount > 1
                RAISERROR('Scanned code "%s" maps to multiple items. Please scan the item code.', 16, 1, @stepInput);
            SET @MasterItemCode = @aliasCode;
        END
    END
    SELECT @FromTrackingEntityBarcode = CONCAT(@FromLocationBarcode, '_', @MasterItemCode)
    INSERT INTO @Output
    SELECT 'FromTrackingEntity',@FromTrackingEntityBarcode
    IF NOT EXISTS(SELECT ID FROM TrackingEntity WHERE Barcode = @FromTrackingEntityBarcode AND Qty>0)
        RAISERROR('There is no stock of %s in the location %s to Putaway',16,1,@MasterItemCode,@FromLocationBarcode)
   
    
	SELECT @valid = 1
	SELECT @message = @FromTrackingEntityBarcode
	SELECT @stepInput =  @FromTrackingEntityBarcode
END TRY
BEGIN CATCH
	SELECT @valid = 0,
	@message = ERROR_MESSAGE()  
END CATCH
 
INSERT INTO @Output (Name, Value)
VALUES
    ('Message',  @message),
    ('Valid',    CONVERT(varchar(10), @valid)),
    ('StepInput',@stepInput);
SELECT * FROM @Output
