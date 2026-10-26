CREATE PROCEDURE [dbo].[PrescriptBlindReceivingNoEntities] (
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
IF ISNUMERIC(@stepInput) = 1
BEGIN
	IF CAST(@stepInput AS int) > 100
	BEGIN
		SELECT @valid = 0
		SELECT @message = 'You are limited to receiving up to 100 TrackingEntity Barcodes at a time'
	END
	ELSE 
	BEGIN
		DECLARE @UserName varchar(30)
		DECLARE @LocationIdentifier varchar (30)
		SELECT @UserName = [Value] FROM @input WHERE [Name] = 'User'
		SELECT @LocationIdentifier = [Value] FROM @input WHERE [Name] = 'Location'
		DECLARE @userID bigint
		DECLARE @masterItemCode nvarchar(50)		
		DECLARE @locationBarcode nvarchar(50)
		DECLARE @processName nvarchar(50)
		DECLARE @numberOfEntities bigint
		DECLARE @batch nvarchar(50)
		DECLARE @expiryDate datetime
		DECLARE @manufactureDate datetime
		DECLARE @serialNumber nvarchar(50)
		DECLARE @comment nvarchar(50)
		DECLARE @reference nvarchar(50)
		DECLARE @palletBarcode nvarchar(50)
		DECLARE @assignTrackingEntityBarcode nvarchar(50)
		DECLARE @qty numeric(19,4)
		DECLARE @responseCode int
		DECLARE @responseJSON nvarchar(max)
		DECLARE @barcodes nvarchar(max)
		SELECT @userID = ID FROM Users WHERE [Name] = @UserName
		SELECT @masterItemCode = [Value] FROM @input WHERE [Name] = 'MasterItem'
		SELECT @locationBarcode = Barcode FROM [Location] WHERE [Name] = @LocationIdentifier OR Barcode = @LocationIdentifier
		SELECT @processName = 'BLINDRECEIVING'
		SELECT @numberOfEntities = [Value] FROM @input WHERE [Name] = 'NoEntities'
		SELECT @reference = [Value] FROM @input WHERE [Name] = 'Document'
		SELECT @palletBarcode = [Value] FROM @input WHERE [Name] = 'CarryingEntity'
		SELECT @qty = CAST(REPLACE((SELECT [Value] FROM @input WHERE [Name] = 'Qty'), ',', '.') AS decimal(19,4))
		EXECUTE [dbo].[clr_TakeOn] 
		   @userID
		  ,@masterItemCode
		  ,@locationBarcode
		  ,@processName
		  ,@numberOfEntities
		  ,@batch
		  ,@expiryDate
		  ,@manufactureDate
		  ,@serialNumber
		  ,@comment
		  ,@reference
		  ,@palletBarcode
		  ,@assignTrackingEntityBarcode
		  ,@qty
		  ,@responseCode OUTPUT
		  ,@responseJSON OUTPUT
		  ,@barcodes OUTPUT
		IF @responseCode = 200
		BEGIN
			SELECT @valid = 1
			DECLARE @MasterItem_id bigint
			DECLARE @Document_id bigint
			DECLARE @ERPLocation varchar (30)
			SELECT @MasterItem_id = ID FROM MasterItem WHERE Code = @masterItemCode
			SELECT @Document_id = ID FROM Document WHERE Number = @reference
			SELECT @ERPLocation = ERPLocation FROM [Location] WHERE Barcode = @locationBarcode
			IF EXISTS (SELECT ID FROM DocumentDetail WHERE Document_id = @Document_id AND Item_id = @MasterItem_id)
			BEGIN
				UPDATE DocumentDetail SET Qty = (Qty + (@qty * @numberOfEntities)), ActionQty = (ActionQty + (@qty * @numberOfEntities)) WHERE Document_id = Document_id AND Item_id = @MasterItem_id
			END
			ELSE
			BEGIN
				INSERT INTO DocumentDetail(Document_id, Item_id, LineNumber, Qty, ActionQty, ToLocation, Completed, AuditDate, AuditUser, [Version])
				SELECT @Document_id, @MasterItem_id, ISNULL(MAX(LineNumber), 0) + 1, (@qty * @numberOfEntities), (@qty * @numberOfEntities), @ERPLocation, 0, GETDATE(), @UserName, 1
				FROM DocumentDetail 
				WHERE Document_id = @Document_id
				AND Item_id = @MasterItem_id
			END
			
			DECLARE @barcode varchar(50)
			DECLARE @labelName varchar(500)
			DECLARE @numberOfLabels int
			DECLARE @printerName varchar(50)
			DECLARE @type varchar(50)
			SELECT @labelName = 'TrackingEntity.zpl'
			SELECT @numberOfLabels = 1
			SELECT @printerName = [Value] FROM @input WHERE [Name] = 'PrinterName'
			SELECT @type = 'TrackingEntity'
			EXECUTE [dbo].[clr_PrintLabel] 
			   @barcode
			  ,@barcodes
			  ,@labelName
			  ,@numberOfLabels
			  ,@printerName
			  ,@type
			  ,@userID
			  ,@responseCode OUTPUT
			  ,@responseJSON OUTPUT
			IF @responseCode = 200
			BEGIN
				SELECT @message = CONCAT(@barcodes, ' created')
			END
			ELSE
			BEGIN
				SELECT @message = CONCAT(@barcodes, ' created but failed to print - use the Reprint Label process')
			END
		END
		ELSE
		BEGIN
			SELECT @valid = 0
			SELECT @message = @responseJSON
		END
	END
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = 'Please enter a numeric value'
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
