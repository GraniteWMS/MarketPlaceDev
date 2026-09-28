CREATE PROCEDURE [dbo].[PrescriptTakeonMasterItem] (
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
DECLARE @LocationIdentifier varchar(40)
DECLARE @Location_Category varchar(30)
DECLARE @MasterItemIdentifier varchar(50)
DECLARE @InputTradingPartnerCode varchar(50)
SELECT @LocationIdentifier = [Value] FROM @input WHERE [Name] = 'Location'
SELECT @Location_Category = Category FROM [Location] WHERE Barcode = @LocationIdentifier OR [Name] = @LocationIdentifier
SELECT @MasterItemIdentifier = @stepInput
SELECT @InputTradingPartnerCode = [Value] FROM @input WHERE [Name] = 'TradingPartner'
IF EXISTS (SELECT ID FROM MasterItemAlias WHERE Code = CONCAT(@InputTradingPartnerCode, @MasterItemIdentifier))
BEGIN
	SELECT @MasterItemIdentifier = CONCAT(@InputTradingPartnerCode, @MasterItemIdentifier)
	SELECT @stepInput = @MasterItemIdentifier
		
END
ELSE IF EXISTS(SELECT ID FROM MasterItem WHERE Code = CONCAT(@InputTradingPartnerCode, @MasterItemIdentifier))
BEGIN
	SELECT @MasterItemIdentifier = CONCAT(@InputTradingPartnerCode, @MasterItemIdentifier)
	SELECT @stepInput = @MasterItemIdentifier
		
END
IF @Location_Category IN ('PICKING', 'BULK')
BEGIN
	DECLARE @Location_CustomerCode varchar(30)
	DECLARE @MasterItem_CustomerCode varchar(30)
	SELECT @Location_CustomerCode = dbo.FN_GetCustomerCode(@LocationIdentifier, 'LOCATION')
	
	SELECT @MasterItem_CustomerCode = dbo.FN_GetCustomerCode(@MasterItemIdentifier, 'MASTERITEM')
	IF (@Location_CustomerCode = @MasterItem_CustomerCode AND @Location_CustomerCode <> 'INVALID') OR ISNULL(@Location_CustomerCode, '') = ''
	BEGIN
		SELECT @valid = 1
	
	END
	ELSE IF (@InputTradingPartnerCode <> @MasterItem_CustomerCode)
	BEGIN
		SELECT @valid = 0
		SELECT @message = CONCAT(@MasterItemIdentifier, ' is linked to customer ', @MasterItem_CustomerCode, ' - You have selected ', @InputTradingPartnerCode)
	END
	ELSE
	BEGIN
		SELECT @valid = 0
		SELECT @message = CONCAT('Location ', @LocationIdentifier, ' already contains stock belonging to customer ', @Location_CustomerCode, 
								', item code ', @MasterItemIdentifier, ' is linked to customer ', @MasterItem_CustomerCode)
	END
END
ELSE
BEGIN
	SELECT @valid = 1
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
