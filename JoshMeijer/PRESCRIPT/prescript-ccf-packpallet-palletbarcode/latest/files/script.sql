CREATE PROCEDURE [dbo].[Prescript_CCF_PACKPALLET_Palletbarcode] (
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
DECLARE @stepInput varchar(MAX) =(SELECT Value FROM @input WHERE Name = 'StepInput')
DECLARE @site varchar(10) = 'CCF'
DECLARE @user varchar(50) = (SELECT Value FROM @input WHERe Name = 'User')
DECLARE @Location varchar(50) = (SELECT Value FROM @input WHERE Name = 'Location')
DECLARE @Location_id bigint = (SELECT ID FROM [Location] WHERE Barcode = @Location or Name = @Location)
DECLARE @CarryingEntity varchar(50) = @stepInput
DECLARE @SSCC varchar(30)
DECLARE @CompanyPrefix varchar(30) = (SELECT Value FROM SystemStaticData 
									  WHERE [Key] = 'CCF_CompanyPrefix' AND [Group] = 'SSCC')
DECLARE @julianDateCode  varchar(5) = dbo.GenerateJulianDateCode(getdate())
DECLARE @Batch varchar(50)
DECLARE @MasterItem varchar(50) ='110028534'
DECLARE @ShelfLife int
DECLARE @ManufactureDate varchar(10)
DECLARE @ExpiryDate varchar(10)
DECLARE @CurrentDate DateTime = getdate()
BEGIN TRY
	IF isnull(@CarryingEntity,'') != ''  
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM CarryingEntity WHERE Barcode = @CarryingEntity)
			RAISERROR('The Entered Pallet barcode %s is not valid',16,1, @CarryingEntity)
		IF SUBSTRING(@Carryingentity,1,2) <> 'PL'
			RAISERROR('The Entered Pallet barcode %s is not valid -It must start with PL',16,1, @CarryingEntity)
	END	
	IF isnull(@CarryingEntity,'') = ''  
	BEGIN	
		BEGIN Tran
			SELECT @CarryingEntity = CONCAT(Prefix,CONVERT(varchar(8),NextBarcode))
			FROM BarcodeMaster WHERE Name = 'PALLET'
			
			UPDATE BarcodeMaster SET NextBarcode = NextBarcode + 1 WHERE Name = 'PALLET'
			SELECT @SSCC = '0' + @CompanyPrefix + SUBSTRING('0000000',1,7-LEN(CONVERT(varchar(7),NextBarcode))) + CONVERT(varchar(7),NextBarcode)
			FROM BarcodeMaster WHERE Name = 'SSCC'
			UPDATE BarcodeMaster SET NextBarcode = NextBarcode + 1 WHERE Name = 'SSCC'
			SELECT @SSCC = '00' + @SSCC + dbo.FN_CalcSSCC_Checkdigit(@SSCC)
			INSERT INTO CarryingEntity (Barcode, CreateDate,Location_id,AuditUser,AuditDate,SSCC)
			SELECT @CarryingEntity,getdate(),@Location_id, @user, getdate(), @SSCC
		COMMIT Tran
		SELECT @message = 'NEW PALLET ASSIGNED AS:' + @CarryingEntity
	END
	
	SELECT @Batch = CONCAT(@julianDateCode,'-',@site)
	INSERT INTO @Output
	SELECT 'Batch', @Batch
	SELECT @ManufactureDate = CONVERT(varchar(8), @CurrentDate, 112)
	INSERT INTO @Output
	SELECT 'ManufactureDate', @ManufactureDate
	SELECT @ShelfLife = isnull(ShelfLife,0) FROM MasterItem WHERE Code = @MasterItem
	IF @ShelfLife = 0 SET @ShelfLife = 30
	SELECT @ExpiryDate = CONVERT(varchar(8), DATEADD(D,@ShelfLife,@CurrentDate),112)
	INSERT INTO @Output
	SELECT 'ExpiryDate', @ExpiryDate
	
	INSERT INTO @Output
	SELECT 'CarryingEntity', @CarryingEntity
	SELECT @stepInput = @CarryingEntity
	SELECT @valid = 1
	
END TRY
BEGIN CATCH
		SELECT @valid = 0
		SELECT @message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
