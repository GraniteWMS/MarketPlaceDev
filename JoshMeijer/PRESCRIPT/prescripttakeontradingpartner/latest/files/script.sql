CREATE PROCEDURE [dbo].[PrescriptTakeonTradingPartner] (
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
DECLARE @TradingPartnerCode varchar(5)
SELECT @TradingPartnerCode = @stepInput
IF NOT EXISTS(SELECT Code, [Description] 
			  FROM TradingPartner
			  WHERE Code = @TradingPartnerCode
				AND Code IN (SELECT [Value] 
							 FROM OptionalFieldValues_MasterItem
							 WHERE isActive = 1))
BEGIN
	SELECT @valid = 0
	SELECT @message = CONCAT(@TradingPartnerCode, ' is not a valid client code - either the client does not exist or Granite has no MasterItems linked to them')
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
