CREATE PROCEDURE [dbo].[Prescript_ReceivingFood_CarryingEntity] (
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
,@LocationID bigint = (SELECT ID FROM dbo.[Location] WHERE Barcode = 'FOOD RECEIVING')
BEGIN TRY
	IF @stepInput = 'NEW PALLET'
	BEGIN
		SELECT @CarryingEntity = CONCAT([Prefix], REPLICATE('0', [Length] - LEN([NextBarcode])), [NextBarcode])
		FROM dbo.BarcodeMaster
		WHERE [Name] = 'PALLET'
		UPDATE dbo.BarcodeMaster
		SET NextBarcode += 1
		WHERE [Name] = 'PALLET'
		INSERT INTO dbo.CarryingEntity(Barcode, CreateDate, Location_id, AuditUser, AuditDate)
		SELECT @CarryingEntity, @CurrentDateTime, @LocationID, @User, @CurrentDateTime
		SET @stepInput = @CarryingEntity
	END
	ELSE
	BEGIN
		IF @stepInput NOT LIKE 'PL%'
		BEGIN
			RAISERROR('Must be a PL barcode', 16, 1)
		END
		IF NOT EXISTS(SELECT ID FROM dbo.CarryingEntity WHERE Barcode = @stepInput)
		BEGIN
			RAISERROR('Pallet barcode %s does not exist', 16, 1, @stepInput)
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
