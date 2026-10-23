CREATE PROCEDURE [dbo].[Prescript_ReceivingNoLabel_Qty] (
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
@Location varchar(50) = 'RECEIVING'
,@MasterItem varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'MasterItem')
,@ExistingTrackingEntityWithSameLocationAndMasterItem varchar(50)
,@UserID bigint = (SELECT ID FROM Users WHERE [Name] = (SELECT [Value] FROM @input WHERE [Name] = 'User'))
,@Printer varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'PrinterName')
,@DocumentID bigint = (SELECT ID FROM Document WHERE Number = (SELECT [Value] FROM @input WHERE [Name] = 'Document'))
,@QtyLeftToReceive bigint
,@MasterItemID bigint
SELECT @MasterItemID = ID FROM MasterItem WHERE Code = @MasterItem
SELECT @QtyLeftToReceive = Qty - ActionQty FROM DocumentDetail WHERE Document_id = @DocumentID AND Item_id = @MasterItemID
BEGIN TRY
	IF ISNULL(@stepInput, '') = 'PRINT ITEM CODE LABELS'
	BEGIN
		
	 
	 
	 
	 
	 
	 
	 
	 
	 
		RAISERROR('Item code label for %s printed', 16, 1, @MasterItem)
	END
	SELECT @ExistingTrackingEntityWithSameLocationAndMasterItem = TE.Barcode
	FROM TrackingEntity TE
	INNER JOIN [Location] L ON TE.Location_id = L.ID
	WHERE 
	TE.MasterItem_id = @MasterItemID
	AND L.Barcode = @Location
	AND TE.Instock = 1
	INSERT INTO @Output
	SELECT 'UseBarcode', @ExistingTrackingEntityWithSameLocationAndMasterItem
	SELECT 
	@valid = 1,
	@message = @stepInput
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
