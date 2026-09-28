CREATE PROCEDURE [dbo].[Prescript_PrintCaseLabel_BBDate] (
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
DECLARE @JulianDate varchar(10) = (SELECT Value FROM @input WHERE Name = 'JulianDate')
DECLARE @ManufactureDate varchar(10) = (SELECT Value FROM @input WHERE Name = 'ManufactureDate')
DECLARE @LotNumber varchar(20) 
BEGIN TRY
	IF isnull(@JulianDate,'') = ''
		SELECT @JulianDate = LEFT(dbo.GetJulianDate(getdate()) ,3)
	SELECT @LotNumber = CONCAT(@JulianDate,@ManufactureDate)
	SELECT @valid = 1, @message = 'Lot Number Saved'
	INSERT INTO @Output
	SELECT 'LotNumber',@LotNumber
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
