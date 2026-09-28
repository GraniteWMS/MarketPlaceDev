CREATE PROCEDURE [dbo].[PrescriptAdjustmentTrackingentity] (
   @input dbo.ScriptInputParameters READONLY
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE @user varchar(30) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @stepInput varchar(MAX) = (SELECT UPPER(Value) FROM @input WHERE Name = 'StepInput') 
DECLARE @TrackingEntity varchar(50)
DECLARE @Location varchar(50) = (SELECT UPPER(Value) FROM @input WHERE Name = 'Location') 
DECLARE @MasterItemCode varchar(50) = (SELECT UPPER(Value) FROM @input WHERE Name = 'MasterItem') 
DECLARE @MasterItemID bigint = (SELECT ID FROM MasterItem WHERE Code = @MasterItemCode)
DECLARE @LocationID bigint = (SELECT ID FROM Location WHERE Barcode = @Location)
SELECT @TrackingEntity = CONCAT(@Location,'_',@MasterItemCode)
IF NOT EXISTS(SELECT ID FROM TrackingEntity WHERE Barcode = @TrackingEntity)
BEGIN
	INSERT INTO TrackingEntity(Barcode,	Qty, CreatedDate, [Location_id], MasterItem_id, InStock, OnHold, StockTake)
	SELECT @TrackingEntity, 0, GETDATE(), @LocationID, @MasterItemID, 1, 0, 0
	SELECT @message = 'Trackingentity Created as:' + @TrackingEntity
END
SELECT @valid = 1
SELECT @message = @TrackingEntity
SELECT @stepInput = @TrackingEntity
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
