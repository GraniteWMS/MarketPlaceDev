CREATE PROCEDURE [dbo].[Prescript_Packing_CarryingEntity] (
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
DECLARE @CarryingEntity varchar(50)
,@User varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'User')
,@CurrentDateTime datetime = GETDATE()
,@LocationID bigint = (SELECT ID FROM dbo.[Location] WHERE Barcode = 'PACKING')
,@CarryingEntityType varchar(20)
BEGIN TRY
	IF ISNULL(@stepInput, '') IN ('NEW BOX', 'NEW LOOSE')
	BEGIN
		SET @CarryingEntityType = IIF(ISNULL(@stepInput, '') = 'NEW BOX', 'BOX', 'LOOSE')
		SELECT @CarryingEntity = CONCAT([Prefix], REPLICATE('0', [Length] - LEN([NextBarcode] + 1)), [NextBarcode] + 1)
		FROM dbo.BarcodeMaster
		WHERE [Name] = @CarryingEntityType
		UPDATE dbo.BarcodeMaster
		SET NextBarcode += 1
		WHERE [Name] = @CarryingEntityType
		INSERT INTO dbo.CarryingEntity(Barcode, CreateDate, Location_id, AuditUser, AuditDate)
		SELECT @CarryingEntity, @CurrentDateTime, @LocationID, @User, @CurrentDateTime
		SET @stepInput = @CarryingEntity
	END
	ELSE
	BEGIN
		IF @stepInput NOT LIKE 'BOX%' OR @stepInput NOT LIKE 'LS%'
		BEGIN
			RAISERROR('Must be a BOX or LOOSE barcode', 16, 1)
		END
		IF NOT EXISTS(SELECT ID FROM dbo.CarryingEntity WHERE Barcode = @stepInput)
		BEGIN
			RAISERROR('Barcode %s does not exist', 16, 1, @stepInput)
		END
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
