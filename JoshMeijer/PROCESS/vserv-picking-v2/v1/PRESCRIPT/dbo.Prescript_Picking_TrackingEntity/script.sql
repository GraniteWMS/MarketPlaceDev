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
SELECT @stepInput = UPPER(Value) FROM @input WHERE Name = 'StepInput' 
DECLARE @YearMonth varchar(6)
,@YearMonthDay varchar(8)
,@EndOfMonth varchar(8)
,@Location varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Location')
,@MasterItem varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'MasterItem')
,@TrackingEntity varchar(50)
DECLARE @LocationID bigint = (SELECT ID FROM [Location] WHERE Barcode = @Location),
@MasterItemID bigint = (SELECT ID FROM MasterItem WHERE Code = @MasterItem)
BEGIN TRY
	IF LEN(@stepInput) <> 6
	BEGIN	
		RAISERROR('Invalid format', 16, 1)
	END
	SET @YearMonth = @stepInput
	SET @YearMonthDay = CONCAT(@YearMonth, '01')
	SET @EndOfMonth = CONVERT(VARCHAR, EOMONTH(@YearMonthDay), 112)
	INSERT INTO @Output
	SELECT 'Comment', @EndOfMonth
	SELECT @TrackingEntity = Barcode
	FROM TrackingEntity
	WHERE MasterItem_id = @MasterItemID
	AND Location_id = @LocationID
	AND ExpiryDate IS NOT DISTINCT FROM CONVERT(DATE, @EndOfMonth)
	AND InStock = 1 AND Qty > 0
	IF ISNULL(@TrackingEntity, '') = ''
	BEGIN
		RAISERROR('Could not find tracking entity in location %s of item code %s with expiry date of %s', 16, 1, @Location, @MasterItem, @EndOfMonth)
	END
	SELECT @stepInput = @TrackingEntity
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
