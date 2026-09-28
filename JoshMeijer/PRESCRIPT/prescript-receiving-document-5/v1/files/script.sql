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
DECLARE @TradingPartnerCode varchar(50)
SELECT @TradingPartnerCode = TradingPartnerCode FROM Document WHERE Number = @stepInput
	SELECT @valid = 1
	SELECT @message = @stepInput
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
