CREATE PROCEDURE [dbo].[Prescript_Picking_TrackingEntity] (
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
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @TrackingEntityBarcode varchar (50)
DECLARE @LocationBarcode varchar (30)
DECLARE @MasterItemCode varchar (40)
DECLARE @MasterItem_id bigint
DECLARE @FirstSpace int
BEGIN TRY
	SELECT @LocationBarcode = TRIM(Value) FROM @input WHERE Name = 'FromLocation' 
 	
	SELECT @FirstSpace = Charindex(' ',@stepInput,0)
	IF @FirstSpace > 0
		SELECT @stepInput = LEFT(@stepInput,@Firstspace-1)
	SELECT @MasterItemCode = @stepInput
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
	SELECT @TrackingEntityBarcode = CONCAT(@LocationBarcode, '_', @MasterItemCode)
	IF NOT EXISTS(SELECT ID FROM TrackingEntity WHERE Barcode = @TrackingEntityBarcode)
		RAISERROR('TrackingEntity %s not found',16,1,@TrackingEntityBarcode)
	SELECT @valid = 1
	SELECT @message = @TrackingEntityBarcode
	SELECT @stepInput =  @TrackingEntityBarcode
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
