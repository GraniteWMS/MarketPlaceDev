CREATE PROCEDURE [dbo].[Prescript_BigPacking_Step200] (
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
@QtyToPackOnDocument decimal(19, 4),
@CarryingEntity varchar(50) = (SELECT Value FROM @input WHERE Name = 'CarryingEntity'),
@Location varchar(50) = (SELECT Value FROM @input WHERE Name = 'PackLocation'),
@User varchar(50) = (SELECT Value FROM @input WHERE Name = 'User'),
@TotalQtyToPack decimal(19, 4),
@CurrentDocumentNumber varchar(50),
@CurrentQty decimal(19, 4),
@Min bigint, @Max bigint, @Counter bigint,
@success bit
SET @QtyToPackOnDocument = @Qty
DECLARE @DocumentsToPack TABLE
(
ID BIGINT IDENTITY(1, 1),
DocumentNumber varchar(50),
Qty decimal(19, 4)
)
DECLARE @QtysToPack TABLE
(
ID BIGINT IDENTITY(1, 1),
DocumentNumber varchar(50),
Qty decimal(19, 4)
)
INSERT INTO @DocumentsToPack(DocumentNumber, Qty)
SELECT
D.Number, SUM(DD.ActionQty) - SUM(ISNULL(DD.PackedQty, 0))
FROM DocumentDetail DD INNER JOIN MasterItem MI ON DD.Item_id = MI.ID
INNER JOIN Document D ON DD.Document_id = D.ID
WHERE D.RouteName = @LinkReference AND MI.Code = @MasterItem AND D.[Type] = 'ORDER'
AND DD.Cancelled = 0
GROUP BY D.Number
HAVING SUM(DD.ActionQty) - SUM(ISNULL(DD.PackedQty, 0)) > 0
SELECT @TotalQtyToPack = ISNULL(SUM(Qty), 0) FROM @DocumentsToPack
SELECT @Min = MIN(ID), @Max = MAX(ID), @Counter = MIN(ID) FROM @DocumentsToPack
WHILE @Counter <= @Max
BEGIN
	SELECT @CurrentDocumentNumber = DocumentNumber, @CurrentQty = Qty FROM @DocumentsToPack WHERE ID = @Counter
	IF @QtyToPackOnDocument > 0
	BEGIN
		IF @QtyToPackOnDocument <= @CurrentQty
		BEGIN 
			INSERT INTO @QtysToPack(DocumentNumber, Qty)
			SELECT @CurrentDocumentNumber, @QtyToPackOnDocument
			SET @QtyToPackOnDocument = 0
		END
		ELSE
		BEGIN
			SET @QtyToPackOnDocument -= @CurrentQty
			INSERT INTO @QtysToPack(DocumentNumber, Qty)
			SELECT @CurrentDocumentNumber, @CurrentQty
		END
	END
	
	SET @Counter += 1
END
BEGIN TRY
	IF @Qty > @TotalQtyToPack
		RAISERROR('Cannot pack more than what is on link reference %s', 16, 1, @LinkReference)
	SELECT @Min = MIN(ID), @Max = MAX(ID), @Counter = MIN(ID) FROM @QtysToPack
	WHILE @Counter <= @Max
	BEGIN
		SELECT @CurrentDocumentNumber = DocumentNumber, @CurrentQty = Qty FROM @QtysToPack WHERE ID = @Counter
		EXECUTE [dbo].[clr_Pack] 
	   @userName = @User
	  ,@documentNumber = @CurrentDocumentNumber
	  ,@carryingEntityIdentifier = @CarryingEntity
	  ,@masterItemIdentifier = @MasterItem
	  ,@locationIdentifier = @Location
	  ,@qty = @CurrentQty
	  ,@comment = NULL
	  ,@reference = @LinkReference
	  ,@integrationReference = NULL
	  ,@processName = 'PACKING'
	  ,@success = @success OUTPUT
	  ,@message = @message OUTPUT
		IF @success = 0
		BEGIN
			RAISERROR(@message, 16, 1)
		END
	
		SET @Counter += 1
	END
	SELECT 
	@valid = 1
	,@message = CONCAT('Packed ', @Qty, ' on ', @LinkReference)
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
