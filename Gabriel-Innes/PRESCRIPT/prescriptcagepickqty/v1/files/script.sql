CREATE PROCEDURE [dbo].[PrescriptCagePickQty] (
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
DECLARE @DocumentNumber varchar(30)
	SELECT @DocumentNumber = Value FROM @input WHERE Name = 'Document'
DECLARE @DocumentId bigint 
	SELECT @DocumentId = ID FROM Document WHERE Number = @DocumentNumber
DECLARE @TradingPartnerCode varchar(30)
	SELECT @TradingPartnerCode = TradingPartnerCode FROM Document WHERE Number = @DocumentNumber
	IF EXISTS(SELECT * FROM Location WHERE Barcode = CONCAT('DIS-', @TradingPartnerCode))
	BEGIN 
		INSERT INTO @Output
		SELECT 'Location', CONCAT('DIS-', @TradingPartnerCode)
	END
	ELSE
	BEGIN
		INSERT INTO @Output
		SELECT 'Location', 'DIS-COL'
	END
	SELECT @valid = 1                  
	SELECT @message = ''  
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
