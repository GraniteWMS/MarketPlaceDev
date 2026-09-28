CREATE PROCEDURE [dbo].[Prescript_Packing_Comment] (
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
,@MasterItem varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'MasterItem')
,@Document varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Document')
,@TotalPickedForItemAndExpiryOnDocument decimal(19, 4)
,@TotalPackedForItemAndExpiryOnDocument decimal(19, 4)
BEGIN TRY
	IF LEN(@stepInput) <> 6
	BEGIN	
		RAISERROR('Invalid format', 16, 1);
	END
	SET @YearMonth = @stepInput;
	SET @YearMonthDay = CONCAT(@YearMonth, '01');
	SET @EndOfMonth = CONVERT(VARCHAR, EOMONTH(@YearMonthDay), 112);
	SET @stepInput = @EndOfMonth;
	SELECT
	@TotalPickedForItemAndExpiryOnDocument = ISNULL(SUM(IIF(T.[Type] = 'PICK', T.ActionQty, 0)), 0),
	@TotalPackedForItemAndExpiryOnDocument = ISNULL(SUM(IIF(T.[Type] = 'PACK', T.ActionQty, 0)), 0)
	FROM dbo.[Transaction] T
	INNER JOIN dbo.Document D ON T.Document_id = D.ID
	INNER JOIN dbo.MasterItem MI ON T.FromMasterItem_id = MI.ID
	WHERE 
	T.[Type] IN ('PICK', 'PACK')
	AND D.Number = @Document
	AND MI.Code = @MasterItem
	AND ISNULL(T.Comment, '') = @EndOfMonth
	AND ISNULL(T.ReversalTransaction_id, 0) = 0;
	IF @TotalPickedForItemAndExpiryOnDocument = @TotalPackedForItemAndExpiryOnDocument
	BEGIN
		RAISERROR('You have fully packed qty for item %s with expiry date %s on document %s', 16, 1, @MasterItem, @EndOfMonth, @Document);
	END
	SELECT 
	@valid = 1,
	@message = @stepInput;
END TRY
BEGIN CATCH
	SELECT 
	@valid = 0,
	@message = ERROR_MESSAGE();
END CATCH
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
