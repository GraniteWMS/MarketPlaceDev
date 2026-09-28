CREATE PROCEDURE [dbo].[PrescriptTakeonCarryingEntity] (
   @input dbo.ScriptInputParameters READONLY
)
AS
DECLARE @Output TABLE(
  Name varchar(max), 
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
SELECT @stepInput = UPPER(@stepInput)
DECLARE @CarryingEntityBarcode varchar (30)
DECLARE @CarryingEntity_ClientCode varchar (5)
DECLARE @InputTradingPartnerCode varchar(5)
SELECT @CarryingEntityBarcode = @stepInput
IF ISNULL(@CarryingEntityBarcode, '') NOT IN('', 'NEW') 
BEGIN
	
	IF EXISTS(SELECT ID FROM CarryingEntity WHERE Barcode = @CarryingEntityBarcode)
	BEGIN
		SELECT @CarryingEntityBarcode = @stepInput
		SELECT @CarryingEntity_ClientCode = ISNULL(dbo.FN_GetCustomerCode(@CarryingEntityBarcode, 'CARRYINGENTITY'), '')
		SELECT @InputTradingPartnerCode = [Value] FROM @input WHERE [Name] = 'TradingPartner'
		IF (@CarryingEntity_ClientCode <> '') AND (@CarryingEntity_ClientCode <> @InputTradingPartnerCode)
		BEGIN
			SELECT @valid = 0
			SELECT @message = CONCAT('Pallet already contains ', @CarryingEntity_ClientCode, ' stock - you have selected ', @InputTradingPartnerCode)
		END
	END
	ELSE
	BEGIN
		SELECT @valid = 0
		SELECT @message = CONCAT(@CarryingEntityBarcode, ' is not a valid pallet barcode')
	END
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
