CREATE PROCEDURE [dbo].[Prescript_ConfirmTransfer_MasterItem] (
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
DECLARE @Document varchar(50)
DECLARE @User varchar(10) = (SELECT [Value] FROM @input WHERE [Name] = 'User')
DECLARE @CurrentDateTime datetime = GETDATE()
DECLARE @DestinationLocation varchar(50)
DECLARE @TransferredQty float
SELECT TOP 1 
@DestinationLocation = DD.ToLocation,
@Document = D.Number
FROM DocumentDetail DD INNER JOIN Document D
ON DD.Document_id = D.ID
WHERE D.Number = (SELECT [Value] FROM @input WHERE [Name] = 'Document')
BEGIN TRY
	IF NOT EXISTS(SELECT * FROM WebTemplate_ConfirmTransfer_MasterItem Where Barcode = @stepInput AND DocumentNumber = @Document)
	BEGIN
		RAISERROR('Barcode %s was already confirmed or was not transferred on document %s', 16, 1, @stepInput, @Document)
	END
	SELECT 
	@TransferredQty = CONVERT(FLOAT, Qty)
	FROM TrackingEntity
	WHERE Barcode = @stepInput
	IF NOT EXISTS(SELECT ID FROM CarryingEntity WHERE Barcode = @Document)
	BEGIN
		INSERT INTO [dbo].[CarryingEntity]
			   ([Barcode]
			   ,[CreateDate]
			   ,[Location_id]
			   ,[AuditUser]
			   ,[AuditDate])
		 SELECT 
		 @Document,
		 @CurrentDateTime,
		 ID,
		 @User,
		 @CurrentDateTime
		 FROM [Location]
		 WHERE Barcode = @DestinationLocation
	END
	INSERT INTO @Output
	SELECT 'Location', @DestinationLocation
	UNION ALL
	SELECT 'CarryingEntity', @Document
	UNION ALL
	SELECT 'Comment', @stepInput
	UNION ALL
	SELECT 'Qty', CONVERT(VARCHAR, @TransferredQty)
	SELECT @valid = 1,
	@message = @stepInput
END TRY
BEGIN CATCH
	SELECT @valid = 0,
	@message = ERROR_MESSAGE()
END CATCH
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
