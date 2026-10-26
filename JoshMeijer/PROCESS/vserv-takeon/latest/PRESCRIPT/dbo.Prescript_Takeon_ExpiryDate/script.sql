CREATE PROCEDURE [dbo].[Prescript_Takeon_ExpiryDate] (
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
DECLARE @YearMonth varchar(6)
,@YearMonthDay varchar(8)
,@EndOfMonth varchar(8)
,@Location varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Location')
,@MasterItem varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'MasterItem')
,@ExistingTrackingEntityWithSameLocationAndExpiry varchar(50)
BEGIN TRY
	IF LEN(@stepInput) <> 6
	BEGIN	
		RAISERROR('Invalid format', 16, 1)
	END
	SET @YearMonth = @stepInput
	SET @YearMonthDay = CONCAT(@YearMonth, '01')
	SET @EndOfMonth = CONVERT(VARCHAR, EOMONTH(@YearMonthDay), 112)
	SET @stepInput = @EndOfMonth
	SELECT @ExistingTrackingEntityWithSameLocationAndExpiry = TE.Barcode
	FROM TrackingEntity TE
	INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
	INNER JOIN [Location] L ON TE.Location_id = L.ID
	WHERE 
	MI.Code = @MasterItem
	AND L.Barcode = @Location
	AND ExpiryDate IS NOT DISTINCT FROM CONVERT(DATE, @EndOfMonth)
	AND TE.Instock = 1
	INSERT INTO @Output
	SELECT 'UseBarcode', @ExistingTrackingEntityWithSameLocationAndExpiry
	SELECT 
	@valid = 1,
	@message = @stepInput
END TRY
BEGIN CATCH
	SELECT 
	@valid = 0,
	@message = ERROR_MESSAGE()
END CATCH
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
