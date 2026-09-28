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
DECLARE @inventoryIdentifier nvarchar(50)
DECLARE @qty numeric(19,4)
DECLARE @comment nvarchar(50)
DECLARE @reference nvarchar(50)
DECLARE @adjustmentType nvarchar(50)
DECLARE @integrationReference nvarchar(50)
DECLARE @processName nvarchar(50)
DECLARE @success bit
DECLARE @subject nvarchar(max)
DECLARE @body nvarchar(max) 
DECLARE @toEmailAddresses nvarchar(max)
DECLARE @ccEmailAddresses nvarchar(max)
DECLARE @bccEmailAddresses nvarchar(max)
DECLARE @reportAttachments nvarchar(max)
DECLARE @excelAttachments nvarchar(max)
DECLARE @fileAttachments nvarchar(max)
BEGIN TRY
	SELECT @TrackingEntityBarcode = [Value] FROM @input WHERE [Name] = 'TrackingEntity'
	SELECT @QtyToAdjustTo = [Value] FROM @input WHERE [Name] = 'Qty'
	SELECT @TrackingEntityQty = Qty FROM TrackingEntity WHERE Barcode = @TrackingEntityBarcode
	SELECT @UserName = [Value] FROM @input WHERE [Name] = 'User'
	SELECT @inventoryIdentifier = @TrackingEntityBarcode
	SELECT @processName = 'ADJUSTTOQTY'
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
	   @userName
	  ,@inventoryIdentifier
	  ,@qty
	  ,@comment
	  ,@reference
	  ,@adjustmentType
	  ,@integrationReference
	  ,@processName
	  ,@success OUTPUT
	  ,@message OUTPUT
	IF @success <> 1
		RAISERROR('Error in Adjustment of %s.  Granite Returned:%s',16,1,@TrackingEntityBarcode, @message)
	SELECT @valid = 1
	,@message = CONCAT('Successfully adjusted ', @TrackingEntityBarcode, ' to ', @QtyToAdjustTo)  
END TRY
BEGIN CATCH
	SELECT @valid = 0
	,@message  = ERROR_MESSAGE()
	
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
