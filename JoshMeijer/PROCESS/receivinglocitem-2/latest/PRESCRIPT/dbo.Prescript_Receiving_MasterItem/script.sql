CREATE PROCEDURE [dbo].[Prescript_Receiving_MasterItem] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max), 
  Value varchar(max)
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @LocationBarcode varchar(50) = (Select Value FROM @input WHERE Name = 'Location')
DECLARE @TrackingEntityBarcode varchar(100)
DECLARE @MasterItemCode varchar (40)
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
	SELECT @TrackingEntityBarcode = CONCAT(@LocationBarcode,'_',@MasterItemCode)
	SELECT @valid = 1
	SELECT @message = CONCAT('Assigned Inventory Identifier is: ' ,@TrackingEntityBarcode)
	INSERT INTO @Output
	SELECT 'UseBarcode', @TrackingEntityBarcode
	SELECT @stepInput = @MasterItemCode
END TRY
BEGIN CATCH
	SELECT @Valid = 0
	,@message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
