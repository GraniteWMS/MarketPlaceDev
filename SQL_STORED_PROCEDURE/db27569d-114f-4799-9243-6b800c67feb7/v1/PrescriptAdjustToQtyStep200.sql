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
DECLARE @UserName varchar(30)

SELECT @TrackingEntityBarcode = [Value] FROM @input WHERE [Name] = 'TrackingEntity'
SELECT @QtyToAdjustTo = [Value] FROM @input WHERE [Name] = 'Qty'
SELECT @TrackingEntityQty = Qty FROM TrackingEntity WHERE Barcode = @TrackingEntityBarcode
SELECT @UserName = [Value] FROM @input WHERE [Name] = 'User'

DECLARE @userID bigint
DECLARE @inventoryIdentifier nvarchar(50)
DECLARE @qty numeric(19,4)
DECLARE @comment nvarchar(50)
DECLARE @reference nvarchar(50)
DECLARE @adjustmentType nvarchar(50)
DECLARE @integrationReference nvarchar(50)
DECLARE @processName nvarchar(50)
DECLARE @responseCode int
DECLARE @responseJSON nvarchar(max)

SELECT @inventoryIdentifier = @TrackingEntityBarcode
SELECT @processName = 'ADJUSTTOQTY'
SELECT @userID = ID FROM Users WHERE [Name] = @UserName

IF @QtyToAdjustTo < @TrackingEntityQty
BEGIN
	SELECT @adjustmentType = 'QtyDecrease'
	SELECT @qty = @TrackingEntityQty - @QtyToAdjustTo
END
ELSE 
BEGIN
	SELECT @adjustmentType = 'QtyIncrease'
	SELECT @qty = @QtyToAdjustTo - @TrackingEntityQty
END

EXECUTE [dbo].[clr_Adjustment] 
   @userID
  ,@inventoryIdentifier
  ,@qty
  ,@comment
  ,@reference
  ,@adjustmentType
  ,@integrationReference
  ,@processName
  ,@responseCode OUTPUT
  ,@responseJSON OUTPUT

IF @responseCode = 200
BEGIN
	SELECT @valid = 1
	SELECT @message = CONCAT('Successfully adjusted ', @TrackingEntityBarcode, ' to ', @QtyToAdjustTo)  
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = @responseJSON
END





	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
