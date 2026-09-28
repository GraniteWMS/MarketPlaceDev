CREATE PROCEDURE [dbo].[Prescript_PeanutRUTFConsume_Qty] (
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
DECLARE 
@ConsumedMasterItem varchar(50),
@ConsumedQty decimal(19, 4) = @stepInput,
@Document varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Document'),
@TrackingEntity varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'TrackingEntity'),
@WastagePercentage decimal(19, 4),
@WastageQty float
SELECT
@WastagePercentage = ISNULL(TRY_CONVERT(DECIMAL(19, 4), DD.Comment), 0)
FROM TrackingEntity TE
INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
INNER JOIN Document D ON D.Number = @Document
INNER JOIN DocumentDetail DD ON DD.Document_id = D.ID AND DD.Item_id = MI.ID
WHERE TE.Barcode = @TrackingEntity
BEGIN TRY
	SET @WastageQty = CONVERT(FLOAT, ISNULL(@ConsumedQty * @WastagePercentage, 0))
	INSERT INTO @Output
	SELECT 'Comment', CONVERT(VARCHAR, @WastageQty)
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
