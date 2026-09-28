CREATE PROCEDURE [dbo].[Prescript_PrintCaseLabel_ManufactureDate] (
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
DECLARE @stepInput varchar(MAX)  = (SELECT Value FROM @input WHERE Name = 'StepInput')
DECLARE @User varchar(50) = (SELECT Value from @input WHERE Name = 'User')
DECLARE @User_id bigint   = (SELECT ID FROM [Users] WHERE Name = @User)
DECLARE @MasterItemCode varchar(100) = (SELECT Value FROM @input WHERE Name = 'MasterItem')
DECLARE @MasterItem_ID BIGINT
DECLARE @ManufactureDate varchar(20) = @stepInput
DECLARE @BBDate varchar(10)
DECLARE @ShelfLife int
DECLARE @JulianDate varchar(10)
BEGIN TRY
	SELECT @MasterItem_ID = ID,@ShelfLife = ShelfLife  FROM MasterItem WHERE Code = @MasterItemCode
	IF isnull(@MasterItem_ID,0) = 0
		RAISERROR('Item Code %s Not found', 16, 1, @StepInput)
	ELSE
	BEGIN
		SELECT @BBDate =  CASE WHEN isnull(@ShelfLife,0) = 0 
								THEN FORMAT(DATEADD(DAY,90,CONVERT(date,@ManufactureDate)),'yyyyMMdd')
								ELSE FORMAT(DATEADD(DAY,isnull(@ShelfLife,90),CONVERT(date,@ManufactureDate)),'yyyyMMdd')
							END
		INSERT INTO @Output
		SELECT 'BBDate', @BBDate
		SELECT @JulianDate = LEFT(dbo.GetJulianDate(CONVERT(date,@ManufactureDate)) ,3)
		INSERT INTO @Output
		SELECT 'JulianDate',@JulianDate
	END
END TRY
BEGIN CATCH
	SELECT @message = isnull(@stepInput,'-') + ERROR_MESSAGE()
	SELECT @valid = 0
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
