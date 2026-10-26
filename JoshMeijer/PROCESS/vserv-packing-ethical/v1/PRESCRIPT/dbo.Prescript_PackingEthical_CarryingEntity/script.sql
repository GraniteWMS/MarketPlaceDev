CREATE PROCEDURE [dbo].[Prescript_PackingEthical_CarryingEntity] (
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
@CurrentDateTime datetime = GETDATE(),
@CurrentUser varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'User'),
@PCrateBarcode varchar(50),
@PCrateBarcodeID bigint,
@PCrateLocation varchar(50)
BEGIN TRY
	SELECT 
	@PCrateBarcodeID = CE.ID,
	@PCrateLocation = L.Barcode
	FROM dbo.CarryingEntity CE
	INNER JOIN [Location] L ON CE.Location_id = L.ID
	WHERE CE.Barcode = @stepInput
	IF ISNULL(@stepInput, '') NOT LIKE 'PC%'
	BEGIN
		RAISERROR('Must be a Picking Crate (PC) barcode', 16, 1)
	END
	IF ISNULL(@PCrateBarcodeID, 0) = 0
	BEGIN
		RAISERROR('PC barcode %s does not exist', 16, 1, @stepInput)
	END
	IF @PCrateLocation <> 'ETHICAL PACKING'
	BEGIN
		RAISERROR('PC barcode %s is open', 16, 1, @stepInput)
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
