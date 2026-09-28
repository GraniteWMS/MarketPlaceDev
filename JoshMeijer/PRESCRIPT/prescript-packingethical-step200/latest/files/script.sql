CREATE PROCEDURE [dbo].[Prescript_PackingEthical_Step200] (
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
SELECT @stepInput = UPPER(Value) FROM @input WHERE Name = 'StepInput' 
DECLARE
@PCrate varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'CarryingEntity'),
@PackingContainers varchar(100) = (SELECT [Value] FROM @input WHERE [Name] = 'Other'),
@User varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'User'),
@UserID bigint,
@CurrentDateTime datetime = GETDATE(),
@LastInvoiceNumber varchar(50),
@Min bigint, @Max bigint, @Counter bigint,
@CurrentItemCode varchar(50), @CurrentQty decimal(19, 4), @CurrentDocumentNumber varchar(50),
@EthicalStagingLocationID bigint = (SELECT ID FROM [Location] WHERE Barcode = 'ETHICAL STAGING')
SELECT @UserID = ID FROM Users WHERE [Name] = @User
DECLARE @PickedQuantities TABLE
(
ID bigint identity(1, 1),
DocumentNumber varchar(50),
ItemCode varchar(50),
Qty decimal(19, 4)
)
DECLARE @UniquePickedDocuments TABLE
(DocumentNumber varchar(50))
INSERT INTO @PickedQuantities (DocumentNumber, ItemCode, Qty)
SELECT DocumentNumber, MasterItemCode, PickedQty
FROM Custom_VW_Ethical_PickingQuantitiesNotPacked
WHERE PCrate = @PCrate
INSERT INTO @UniquePickedDocuments(DocumentNumber)
SELECT DISTINCT DocumentNumber FROM @PickedQuantities
SELECT @Min = MIN(ID), @Max = MAX(ID), @Counter = MIN(ID) FROM @PickedQuantities
BEGIN TRY
	INSERT INTO CarryingEntity(Barcode, CreateDate, Location_id, AuditDate, AuditUser)
	SELECT DocumentNumber, @CurrentDateTime, L.ID, @CurrentDateTime, @User FROM 
	@UniquePickedDocuments AS PickedDocuments
	INNER JOIN [Location] L ON L.Barcode = 'ETHICAL PACKING'
	WHERE NOT EXISTS(SELECT ID FROM CarryingEntity WHERE Barcode = PickedDocuments.DocumentNumber)
	WHILE @Counter >= @Min AND @Counter <= @Max
	BEGIN
		SELECT 
		@CurrentDocumentNumber = DocumentNumber,
		@CurrentItemCode = ItemCode, 
		@CurrentQty = Qty 
		FROM @PickedQuantities 
		WHERE ID = @Counter
		EXECUTE [dbo].[clr_Pack] 
	   @userName = @User
	  ,@documentNumber = @CurrentDocumentNumber
	  ,@carryingEntityIdentifier = @CurrentDocumentNumber
	  ,@masterItemIdentifier = @CurrentItemCode
	  ,@locationIdentifier = 'ETHICAL PACKING'
	  ,@qty = @CurrentQty
	  ,@comment = @PackingContainers
	  ,@reference = @PCrate
	  ,@integrationReference = NULL
	  ,@processName = 'PACKING_ETHICAL'
	  ,@success = @valid OUTPUT
	  ,@message = @message OUTPUT
	  IF @valid = 0
	  BEGIN
			RAISERROR(@message, 16, 1)
	  END
		SET @Counter += 1;
	END
	UPDATE CarryingEntity
	SET Location_id = @EthicalStagingLocationID
	WHERE Barcode = @PCrate
	
	
	
	
	
	
	
	
	
	
	
	SELECT 
	@valid = 1,
	@message = 'Stock on picking crate is packed'
END TRY
BEGIN CATCH
	SELECT 
	@valid = 0,
	@message = ERROR_MESSAGE()
END CATCH
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
