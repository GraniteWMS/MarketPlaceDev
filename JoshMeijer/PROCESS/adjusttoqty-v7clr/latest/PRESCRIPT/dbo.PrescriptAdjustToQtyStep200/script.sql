CREATE PROCEDURE [dbo].[PrescriptAdjustToQtyStep200] (
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
DECLARE @TrackingEntityBarcode varchar(50)
DECLARE @TrackingEntityQty decimal(19,4)
DECLARE @QtyToAdjustTo decimal(19, 4)
DECLARE @userName varchar(30)
SELECT @TrackingEntityBarcode = [Value] FROM @input WHERE [Name] = 'TrackingEntity'
SELECT @QtyToAdjustTo = [Value] FROM @input WHERE [Name] = 'Qty'
SELECT @TrackingEntityQty = Qty FROM TrackingEntity WHERE Barcode = @TrackingEntityBarcode
SELECT @userName = [Value] FROM @input WHERE [Name] = 'User'
DECLARE @userID bigint
DECLARE @trackingEntityIdentifier nvarchar(50)
DECLARE @trackingEntityOptionalFields nvarchar(max)
DECLARE @adjustmentqty numeric(19,4)
DECLARE @comment nvarchar(50)
DECLARE @reference nvarchar(50)
DECLARE @adjustmentType nvarchar(50)
DECLARE @integrationReference nvarchar(50)
DECLARE @processName nvarchar(50)
DECLARE @success int
SELECT @trackingEntityIdentifier = @TrackingEntityBarcode
SELECT @processName = 'ADJUSTTOQTY'
SELECT @userID = ID FROM Users WHERE [Name] = @userName
IF @QtyToAdjustTo < @TrackingEntityQty
BEGIN
	SELECT @adjustmentType = 'QtyDecrease'
	SELECT @adjustmentqty = @TrackingEntityQty - @QtyToAdjustTo
END
ELSE 
BEGIN
	SELECT @adjustmentType = 'QtyIncrease'
	SELECT @adjustmentqty = @QtyToAdjustTo - @TrackingEntityQty
END
EXECUTE [dbo].[clr_Adjustment] 
   @userName
  ,@trackingEntityIdentifier
  ,@adjustmentqty
  ,@comment
  ,@reference
  ,@adjustmentType
  ,@integrationReference
  ,@processName
  ,@trackingEntityOptionalFields
  ,@success OUTPUT
  ,@message OUTPUT
IF @success = 1
BEGIN
	SELECT @valid = 1
	SELECT @message = CONCAT('Successfully adjusted ', @TrackingEntityBarcode, ' to ', @QtyToAdjustTo)  
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = @message
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
