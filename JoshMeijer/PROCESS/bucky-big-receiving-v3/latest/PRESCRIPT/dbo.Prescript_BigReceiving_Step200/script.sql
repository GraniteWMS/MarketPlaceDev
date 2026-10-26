CREATE PROCEDURE [dbo].[Prescript_BigReceiving_Step200] (
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
DECLARE 
@MasterItem varchar(50) = (SELECT Value FROM @input WHERE Name = 'MasterItem'),
@LinkReference varchar(50) = (SELECT Value FROM @input WHERE Name = 'Document'),
@Qty decimal(19, 4) = (SELECT CONVERT(decimal(19, 4), Value) FROM @input WHERE Name = 'Qty'),
@Location varchar(50) = (SELECT Value FROM @input WHERE Name = 'ReceivingLocation'),
@Batch varchar(50) = (SELECT Value FROM @input WHERE Name = 'Batch'),
@ExpiryDate varchar(50) = (SELECT CONVERT(DATETIME, Value) FROM @input WHERE Name = 'ExpiryDate'),
@CarryingEntity varchar(50) = (SELECT Value FROM @input WHERE Name = 'CarryingEntity'),
@User bigint = (SELECT Value FROM @input WHERE Name = 'User'),
@UseBarcode varchar(50) = (SELECT Value FROM @input WHERE Name = 'UseBarcode'),
@Printer varchar(50) = (SELECT Value FROM @input WHERE Name = 'PrinterName'),
@TotalQtyToReceive decimal(19, 4),
@CurrentDocumentNumber varchar(50),
@CurrentQty decimal(19, 4),
@Min bigint, @Max bigint, @Counter bigint,
@success bit,
@barcodes [nvarchar](max),
@QtyToReceiveOnDocument decimal(19, 4)
DECLARE @UserID bigint = (SELECT ID FROM Users WHERE [Name] = @User)
SET @QtyToReceiveOnDocument = @Qty
DECLARE @DocumentsToReceive TABLE
(
ID BIGINT IDENTITY(1, 1),
DocumentNumber varchar(50),
Qty decimal(19, 4)
)
DECLARE @QtysToReceive TABLE
(
ID BIGINT IDENTITY(1, 1),
DocumentNumber varchar(50),
Qty decimal(19, 4)
)
INSERT INTO @DocumentsToReceive(DocumentNumber, Qty)
SELECT
D.Number, SUM(DD.Qty) - SUM(ISNULL(DD.ActionQty, 0))
FROM DocumentDetail DD INNER JOIN MasterItem MI ON DD.Item_id = MI.ID
INNER JOIN Document D ON DD.Document_id = D.ID
WHERE D.RouteName = @LinkReference AND MI.Code = @MasterItem AND D.[Type] = 'RECEIVING'
AND D.[Status] NOT IN ('CANCELLED', 'COMPLETE')
AND DD.Completed = 0
AND DD.Cancelled = 0
GROUP BY D.Number
HAVING SUM(DD.Qty) - SUM(ISNULL(DD.ActionQty, 0)) > 0
SELECT @TotalQtyToReceive = ISNULL(SUM(Qty), 0) FROM @DocumentsToReceive
SELECT @Min = MIN(ID), @Max = MAX(ID), @Counter = MIN(ID) FROM @DocumentsToReceive
WHILE @Counter <= @Max
BEGIN
	SELECT @CurrentDocumentNumber = DocumentNumber, @CurrentQty = Qty FROM @DocumentsToReceive WHERE ID = @Counter
	IF @QtyToReceiveOnDocument > 0
	BEGIN
		IF @QtyToReceiveOnDocument <= @CurrentQty
		BEGIN 
			INSERT INTO @QtysToReceive(DocumentNumber, Qty)
			SELECT @CurrentDocumentNumber, @QtyToReceiveOnDocument
			SET @QtyToReceiveOnDocument = 0
		END
		ELSE
		BEGIN
			SET @QtyToReceiveOnDocument -= @CurrentQty
			INSERT INTO @QtysToReceive(DocumentNumber, Qty)
			SELECT @CurrentDocumentNumber, @CurrentQty
		END
	END
	
	SET @Counter += 1
END
BEGIN TRY
	IF @Qty > @TotalQtyToReceive
		RAISERROR('Cannot receive more than what is on link reference %s', 16, 1, @LinkReference)
	SELECT @Min = MIN(ID), @Max = MAX(ID), @Counter = MIN(ID) FROM @QtysToReceive
	WHILE @Counter <= @Max
	BEGIN
		SELECT @CurrentDocumentNumber = DocumentNumber, @CurrentQty = Qty FROM @QtysToReceive WHERE ID = @Counter
		EXECUTE [dbo].[clr_Receive] 
	   @userName = @User
	  ,@documentNumber = @CurrentDocumentNumber
	  ,@trackingEntityIdentifier = @UseBarcode
	  ,@locationIdentifier = @Location
	  ,@masterItemIdentifier = @MasterItem
	  ,@qty = @CurrentQty
	  ,@carryingEntityIdentifier = @CarryingEntity
	  ,@batch = @Batch
	  ,@serialNumber = NULL
	  ,@expiryDate = @ExpiryDate
	  ,@manufactureDate = NULL
	  ,@numberOfEntities = 1
	  ,@comment = NULL
	  ,@reference = @LinkReference
	  ,@integrationReference = NULL
	  ,@processName = 'RECEIVING'
	  ,@success = @success OUTPUT
	  ,@message = @message  OUTPUT
	  ,@barcodes = @barcodes OUTPUT
		IF @success = 0
		BEGIN
			RAISERROR(@message, 16, 1)
		END
		IF @Counter = 1
		BEGIN
			SET @UseBarcode = @barcodes;
		END
	
		SET @Counter += 1
	END
	SELECT @valid = 1
	, @message = CONCAT('Received ', @Qty, ' with expiry ', @ExpiryDate)
	EXECUTE [dbo].[clr_PrintLabel] 
   @barcode = @UseBarcode
  ,@barcodes = NULL
  ,@labelName = 'TrackingEntity.zpl'
  ,@numberOfLabels = 1
  ,@printerName = @Printer
  ,@type = 'TRACKINGENTITY'
  ,@userID = @UserID
  ,@success = @success OUTPUT
  ,@message = @message OUTPUT
END TRY
BEGIN CATCH
	SELECT @valid = 0
	, @message = ERROR_MESSAGE()
END CATCH
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
