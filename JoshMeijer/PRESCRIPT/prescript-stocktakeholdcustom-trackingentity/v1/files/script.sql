CREATE PROCEDURE [dbo].[Prescript_StockTakeHoldCustom_TrackingEntity] (
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
DECLARE @Qty int
DECLARE @Location varchar(20)
DECLARE @Batch varchar(50)
DECLARE @MasterItem varchar(50)
IF EXISTS(SELECT * FROM TrackingEntity WHERE Barcode = @stepInput AND InStock = 1)
BEGIN
	SELECT @Qty = Qty, @Batch = Batch FROM TrackingEntity WHERE Barcode = @stepInput
	SELECT @Location = Barcode FROM Location WHERE ID = (SELECT Location_id FROM TrackingEntity WHERE Barcode = @stepInput)
	SELECT @MasterItem = Code FROM MasterItem WHERE ID = (SELECT MasterItem_id FROM TrackingEntity WHERE Barcode = @stepInput)
	INSERT INTO @Output
	SELECT 'CLocation', @Location
	INSERT INTO @Output
	SELECT 'CQty', @Qty
	INSERT INTO @Output
	SELECT 'CBatch', @Batch
	INSERT INTO @Output
	SELECT 'CMasterItem', @MasterItem
	SELECT @valid = 1
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = 'Barcode not in stock'
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
