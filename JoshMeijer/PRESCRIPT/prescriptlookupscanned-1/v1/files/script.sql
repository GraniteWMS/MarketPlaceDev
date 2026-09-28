CREATE PROCEDURE [dbo].[PrescriptLookupScanned] (
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
SELECT @stepInput = TRIM(Value) FROM @input WHERE Name = 'StepInput' 
DECLARE @MasterItemCode varchar (40)
DECLARE @FirstSpace int
BEGIN TRY
 	
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
			SELECT @MasterItemCode = @aliasCode;
        END
    END
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
