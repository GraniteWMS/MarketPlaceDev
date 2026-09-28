CREATE PROCEDURE [dbo].[Prescript_Receiving_Document] (
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
DECLARE @DocumentStatus varchar(30)
DECLARE @TradingPartnerCode varchar(50)
SELECT @TradingPartnerCode = TradingPartnerCode, @DocumentStatus = [Status] FROM Document WHERE Number = @stepInput
IF @DocumentStatus IN ('RELEASED')
BEGIN
	SELECT @valid = 1
	SELECT @message = @stepInput
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = 'The Entered Document is not RELEASED for Receiving'
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
