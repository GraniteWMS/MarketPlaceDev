CREATE PROCEDURE [dbo].[Prescript_StockTakeHoldCustom_Qty] (
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
DECLARE @Qty int
DECLARE @Location varchar(20)
DECLARE @Barcode varchar(30)
SELECT @Barcode = [Value] FROM @input WHERE [Name] = 'CTrackingEntity'
SELECT @Location = [Value] FROM @input WHERE [Name] = 'CLocation'
SELECT @Qty = @stepInput
IF (SELECT Stocktake FROM TrackingEntity WHERE Barcode = @Barcode) = 1
BEGIN
	SELECT @message = CONCAT('Barcode ', @Barcode, ' released. Qty and Location updated')
END
ELSE
BEGIN
	SELECT @message = CONCAT('Barcode ', @Barcode, ' not on hold. Qty and Location updated')
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
