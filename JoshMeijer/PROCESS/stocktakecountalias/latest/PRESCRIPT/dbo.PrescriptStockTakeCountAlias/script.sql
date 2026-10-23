CREATE PROCEDURE [dbo].[PrescriptStockTakeCountAlias] (
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
DECLARE @TrackingEntity varchar(50)
DECLARE @Alias varchar(30)
SELECT @TrackingEntity = value FROM @input WHERE Name = 'Entity'
SELECT @Alias = @stepInput
IF NOT EXISTS(SELECT Alias FROM Custom_StockTakeCountAlias WHERE TrackingEntityBarcode = @TrackingEntity AND Alias = @Alias)
BEGIN
	SELECT @message = 'Scan a valid Alias'
	SELECT @valid = 0
END
ELSE
BEGIN
	SELECT @stepInput = @TrackingEntity
	SELECT @message = @TrackingEntity
	SELECT @valid = 1
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output