CREATE PROCEDURE [dbo].[Prescript_PrintCaseLabel_Step200] (
   @input dbo.ScriptInputParameters READONLY
)
AS
DECLARE @Output TABLE(
  Name varchar(max), 
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput'
DECLARE @UserID bigint
DECLARE @User varchar(MAX) 
DECLARE @PrinterName varchar(50) = (SELECT Value FROM @input WHERE Name = 'PrinterName')
DECLARE @MasterItem varchar(200) = (SELECT Value FROM @input WHERE Name = 'MasterItem')
DECLARE @JulianDate varchar(10)
DECLARE @Plant varchar(10) = (SELECT Value FROM SystemStaticData WHERe [Key] = 'Plant') 
DECLARE @BBDate varchar(20) = (SELECT Value FROM @input WHERE Name = 'BBDate')
DECLARE @ManufactureDate varchar(20) = (SELECT Value FROM @input WHERE Name = 'ManufactureDate')
DECLARE @LotNumber varchar(20) = (SELECT Value FROM @input WHERE Name = 'LotNumber')
DECLARE @GS1Human varchar(50)
DECLARE @GS1Barcode varchar(50)
DECLARE @NumberofLabels int = (SELECT TRY_CONVERT(int,Value) FROM @input WHERE Name = 'NumberOfLabels')
DECLARE @CASE_GTIN varchar(20)
BEGIN TRY
	SELECT @JulianDate = Value FROM @input WHERE Name = 'JulianDate'
	IF isnull(@JulianDate,'') = ''
		SELECT @JulianDate = LEFT(dbo.GetJulianDate(CONVERT(date,@ManufactureDate)) ,3)
	IF isnull(@JulianDate,'') = ''
		SELECT @JulianDate = dbo.GetJulianDate(getdate()) 
	SELECT @CASE_GTIN = CASE_GTIN FROM Label_MasterItem WHERe Code = @MasterItem
	SELECT @LotNumber = CONCAT(@JulianDate,@ManufactureDate)
	SELECT @BBDate = SUBSTRING(@BBDate,3,6)
	SELECT @GS1Human = CONCAT('(01)',@CASE_GTIN,'(15)',@BBDate,'(10)',@LotNumber)
	SELECT @GS1Barcode = CONCAT('>;>801',@CASE_GTIN,'15',@BBDate,'>610',@LotNumber)
	
	DELETE FROM custom_CurrentCaseLabelVariables WHERE MasterItemCode = @MasterItem
	INSERT INTO custom_CurrentCaseLabelVariables(MasterItemCode, JulianDate, Plant,BBDate,GS1Human, GS1Barcode)
	SELECT @MasterItem,@JulianDate,@Plant,@BBDate,@GS1Human,@GS1Barcode
	SELECT @User = Value FROM @input WHERE Name = 'User' 
	SELECT @UserID = ID FROM [Users] WHERE Name = @User
	DECLARE @responseCode int, @responseJSON varchar(max)
	EXECUTE [dbo].[clr_PrintLabel] 
		@MasterItem
		,''
		,'MASTERITEM.ZPL'
		,@NumberofLabels
		,@PrinterName
		,'MASTERITEM'
		,@UserID
		,@responseCode OUTPUT
		,@responseJSON OUTPUT
		SELECT @responseCode
		SELECT @responseJSON
		IF @responseCode = 200 or @responseCode = 1
			SELECT @valid = 1, @message = 'Label(s) printed'
		ELSE
			RAISERROR('Error printing:%s',16,1,@responseJSON)
		SELECT @valid = 1, @message = 'Printed:' + convert(varchar(10),isnull(@responseCode,0)) + ':' + isnull(@responseJSON,'')
END TRY
BEGIN CATCH
			SELECT @Valid = 0
			SELECT @message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
