CREATE PROCEDURE [dbo].[Prescript_BigPicking_Step200] (
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
@MasterItem varchar(50),
@LinkReference varchar(50) = (SELECT Value FROM @input WHERE Name = 'Document'),
@Qty decimal(19, 4) = (SELECT CONVERT(decimal(19, 4), Value) FROM @input WHERE Name = 'Qty'),
@QtyToPickOnDocument decimal(19, 4),
@TrackingEntity varchar(100) = (SELECT Value FROM @input WHERE Name = 'TrackingEntity'),
@Location varchar(50) = (SELECT Value FROM @input WHERE Name = 'PickLocation'),
@User varchar(50) = (SELECT Value FROM @input WHERE Name = 'User'),
@TotalQtyToPick decimal(19, 4),
@CurrentDocumentNumber varchar(50),
@CurrentQty decimal(19, 4),
@Min bigint, @Max bigint, @Counter bigint,
@success bit,
@barcodes [nvarchar](max),
@TrackingEntityERPLocation varchar(30)
SET @QtyToPickOnDocument = @Qty
SELECT 
@MasterItem = MI.Code,
@TrackingEntityERPLocation = L.ERPLocation
FROM TrackingEntity TE INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
INNER JOIN [Location] L ON TE.Location_id = L.ID
WHERE TE.Barcode = @TrackingEntity
DECLARE @DocumentsToPick TABLE
(
ID BIGINT IDENTITY(1, 1),
DocumentNumber varchar(50),
Qty decimal(19, 4)
)
DECLARE @QtysToPick TABLE
(
ID BIGINT IDENTITY(1, 1),
DocumentNumber varchar(50),
Qty decimal(19, 4)
)
INSERT INTO @DocumentsToPick(DocumentNumber, Qty)
SELECT
D.Number, SUM(DD.Qty) - SUM(ISNULL(DD.ActionQty, 0))
FROM DocumentDetail DD INNER JOIN MasterItem MI ON DD.Item_id = MI.ID
INNER JOIN Document D ON DD.Document_id = D.ID
WHERE D.RouteName = @LinkReference AND MI.Code = @MasterItem AND D.[Type] = 'ORDER'
AND D.[Status] NOT IN ('CANCELLED', 'COMPLETE')
AND DD.Completed = 0
AND DD.Cancelled = 0
AND DD.FromLocation = @TrackingEntityERPLocation
GROUP BY D.Number
HAVING SUM(DD.Qty) - SUM(ISNULL(DD.ActionQty, 0)) > 0
SELECT @TotalQtyToPick = ISNULL(SUM(Qty), 0) FROM @DocumentsToPick
SELECT @Min = MIN(ID), @Max = MAX(ID), @Counter = MIN(ID) FROM @DocumentsToPick
WHILE @Counter <= @Max
BEGIN
	SELECT @CurrentDocumentNumber = DocumentNumber, @CurrentQty = Qty FROM @DocumentsToPick WHERE ID = @Counter
	IF @QtyToPickOnDocument > 0
	BEGIN
		IF @QtyToPickOnDocument <= @CurrentQty
		BEGIN 
			INSERT INTO @QtysToPick(DocumentNumber, Qty)
			SELECT @CurrentDocumentNumber, @QtyToPickOnDocument
			SET @QtyToPickOnDocument = 0
		END
		ELSE
		BEGIN
			SET @QtyToPickOnDocument -= @CurrentQty
			INSERT INTO @QtysToPick(DocumentNumber, Qty)
			SELECT @CurrentDocumentNumber, @CurrentQty
		END
	END
	
	SET @Counter += 1
END
BEGIN TRY
	IF @Qty > @TotalQtyToPick
		RAISERROR('Cannot Pick more than what is on link reference %s', 16, 1, @LinkReference)
	SELECT @Min = MIN(ID), @Max = MAX(ID), @Counter = MIN(ID) FROM @QtysToPick
	WHILE @Counter <= @Max
	BEGIN
		SELECT @CurrentDocumentNumber = DocumentNumber, @CurrentQty = Qty FROM @QtysToPick WHERE ID = @Counter
		EXECUTE [dbo].[clr_Pick] 
	   @userName = @User
	  ,@documentNumber = @CurrentDocumentNumber
	  ,@inventoryIdentifier = @TrackingEntity
	  ,@locationIdentifier = @Location
	  ,@uom = NULL
	  ,@qty = @CurrentQty
	  ,@comment = NULL
	  ,@reference = @LinkReference
	  ,@integrationReference = NULL
	  ,@processName = 'PICKING'
	  ,@success = @success OUTPUT
	  ,@message = @message OUTPUT
		IF @success = 0
		BEGIN
			RAISERROR(@message, 16, 1)
		END
	
		SET @Counter += 1
	END
	SELECT @valid = 1
	, @message = CONCAT('Picked ', @Qty, ' On ', @TrackingEntity)
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
