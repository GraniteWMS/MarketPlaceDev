CREATE PROCEDURE [dbo].[PrescriptAddEANBarcodeConfirmation] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 0
DECLARE @message varchar(MAX) = 'Could not capture barcode'
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @MasterItem varchar(50)
DECLARE @MasterItemID bigint = 0
DECLARE @User varchar(50)
DECLARE @ERPIdentification varchar(30) = 0
DECLARE @EANBarcode varchar(50)
SELECT @MasterItem = Value FROM @input WHERE Name = 'MasterItem'
SELECT @MasterItemID = ID, @ERPIdentification = ERPIdentification FROM MasterItem WHERE Code = @MasterItem
SELECT @User = Value FROM @input WHERE Name = 'User'
SELECT @EANBarcode = Value FROM @input WHERE Name = 'EANBarcode'
IF @MasterItemID <> 0 AND @ERPIdentification <> 0 AND UPPER(@stepInput) = 'YES'
BEGIN
	BEGIN TRY
		INSERT INTO [MasterItemAlias] (Code, UOM, IsActive, AuditDate, AuditUser, MasterItem_id, [Version], ERPIdentification)
		VALUES (@EANBarcode, 'Each', 1, GETDATE(), @User, @MasterItemID, CONVERT(smallint, 0), @ERPIdentification)
	
		SELECT @valid = 1
		SELECT @message = 'Barcode Captured'
	END TRY
	BEGIN CATCH
		SELECT @valid = 0
		SELECT @message = 'Something went wrong'
	END CATCH
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
