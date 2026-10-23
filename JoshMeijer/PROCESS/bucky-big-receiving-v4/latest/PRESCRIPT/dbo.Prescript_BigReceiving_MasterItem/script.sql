CREATE PROCEDURE [dbo].[Prescript_BigReceiving_MasterItem] (
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
@MasterItemCode varchar(50)
,@MasterItemID bigint
,@LinkReference varchar(50) = (SELECT Value FROM @input WHERE Name = 'Document')
SELECT @MasterItemID = ID FROM MasterItem WHERE Code = @stepInput or FormattedCode = @stepInput
BEGIN TRY
	IF ISNULL(@MasterItemID, 0) <> 0
	BEGIN
		SELECT @MasterItemCode = @stepInput
	END
	ELSE
	IF EXISTS(SELECT ID FROM MasterItemAlias_View WHERE Code = @stepInput)
	BEGIN
		SELECT TOP 1 @MasterItemID = MasterItem_id FROM  MasterItemAlias_View WHERE Code = @stepInput
		SELECT @MasterItemCode = Code FROM MasterItem WHERE ID = @MasterItemID
		SELECT @stepInput = @MasterItemCode
	END
	ELSE
	BEGIN
		RAISERROR(N'Could Not Find Item or Alias %s', 16, 1, @stepInput)
	END
	IF NOT EXISTS(
	SELECT DD.ID FROM DocumentDetail DD
	INNER JOIN Document D ON DD.Document_id = D.ID
	WHERE DD.Item_id = @MasterItemID
	AND D.[Type] = 'RECEIVING'
	AND D.RouteName = @LinkReference
	AND DD.Completed = 0
	AND DD.Cancelled = 0
	AND DD.Qty <> DD.ActionQty)
	BEGIN
		RAISERROR(N'Item %s Not Found On Link Reference %s', 16, 1, @MasterItemCode, @LinkReference)
	END
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
