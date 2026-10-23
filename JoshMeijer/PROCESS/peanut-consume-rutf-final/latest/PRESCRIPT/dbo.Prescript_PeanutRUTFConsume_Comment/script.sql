CREATE PROCEDURE [dbo].[Prescript_PeanutRUTFConsume_Comment] (
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
@ConsumedQty decimal(19, 4) = (SELECT [Value] FROM @input WHERE [Name] = 'Qty'),
@WastageQty decimal(19, 4) = ISNULL(TRY_CONVERT(DECIMAL(19, 4), @stepInput), 0)
BEGIN TRY
	IF @WastageQty >= @ConsumedQty
	BEGIN
		RAISERROR('The wastage quantity cannot be larger or equal to the consumed quantity', 16, 1)
	END
	SELECT 
	@valid = 1,
	@message = @WastageQty
	
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
