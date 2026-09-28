CREATE PROCEDURE [dbo].[Prescript_Receiving_Qty] (
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
@MasterItem varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'MasterItem'),
@DocumentID bigint = (SELECT ID FROM Document WHERE Number = (SELECT [Value] FROM @input WHERE [Name] = 'Document')),
@QtyLeftToReceive bigint,
@MasterItemID bigint,
@Printer varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'PrinterName')
SELECT @MasterItemID = ID FROM MasterItem WHERE Code = @MasterItem
SELECT @QtyLeftToReceive = Qty - ActionQty FROM DocumentDetail WHERE Document_id = @DocumentID AND Item_id = @MasterItemID
BEGIN TRY
	IF ISNULL(@stepInput, '') = 'PRINT ITEM CODE LABEL'
	BEGIN
		
	 
	 
	 
	 
	 
	 
	 
	 
	 
		RAISERROR('Item code label for %s printed', 16, 1, @MasterItem)
	END
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