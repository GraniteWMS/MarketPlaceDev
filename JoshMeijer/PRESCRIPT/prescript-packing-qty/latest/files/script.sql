CREATE PROCEDURE [dbo].[Prescript_Packing_Qty] (
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
DECLARE 
@ExpiryDate varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Comment')
,@MasterItem varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'MasterItem')
,@Document varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Document')
,@TotalPickedForItemAndExpiryOnDocument decimal(19, 4)
,@TotalPackedForItemAndExpiryOnDocument decimal(19, 4)
,@QtyToPack decimal(19, 4) = CONVERT(DECIMAL(19, 4), @stepInput)
BEGIN TRY
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
	AND ISNULL(T.Comment, '') = @ExpiryDate
	AND ISNULL(T.ReversalTransaction_id, 0) = 0;
	IF @TotalPickedForItemAndExpiryOnDocument < @TotalPackedForItemAndExpiryOnDocument + @QtyToPack
	BEGIN
		RAISERROR('You cannot pack more for item %s with expiry date %s on document %s than what was picked', 16, 1, @MasterItem, @ExpiryDate, @Document);
	END
	SELECT 
	@valid = 1,
	@message = '';
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
