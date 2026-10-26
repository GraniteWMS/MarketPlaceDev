CREATE PROCEDURE [dbo].[Prescript_PrintCaseLabel_MasterItem] (
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
DECLARE @MasterItemCode varchar(200) = @stepInput
DECLARE @JulianDate varchar(10)
DECLARE @BBDate varchar(10)
DECLARE @ShelfLife int
DECLARE @MasterItem_ID bigint
BEGIN TRY
	SELECT @MasterItem_ID = ID,@ShelfLife = ShelfLife  FROM MasterItem WHERE Code = @MasterItemCode
	IF isnull(@MasterItem_ID,0) = 0
		RAISERROR('Item Code %s Not found', 16, 1, @StepInput)
	SELECT @BBDate =  CASE WHEN isnull(@ShelfLife,0) = 0 
								THEN FORMAT(DATEADD(DAY,90,CONVERT(date,getdate())),'yyyyMMdd')
								ELSE FORMAT(DATEADD(DAY,isnull(@ShelfLife,90),CONVERT(date,getdate())),'yyyyMMdd')
						END
	INSERT INTO @Output
	SELECT 'ManufactureDate', FORMAT(CONVERT(date,getdate()),'yyyyMMdd')
	INSERT INTO @Output
	SELECT 'BBDate', @BBDate
	SELECT @valid = 1, @message = ''
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
