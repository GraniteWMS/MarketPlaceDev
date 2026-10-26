CREATE PROCEDURE [dbo].[Prescript_Transfer_TrackingEntity] (
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
DECLARE @DestinationLocation varchar(50) = 
(SELECT TOP 1 DD.ToLocation 
FROM DocumentDetail DD INNER JOIN Document D
ON DD.Document_id = D.ID
WHERE D.Number = (SELECT Value FROM @input WHERE Name = 'Document')),
@TrackingEntityQty decimal(19, 4),
@BarcodeIsOnhold bit
SELECT 
@BarcodeIsOnhold = OnHold,
@TrackingEntityQty = Qty
FROM TrackingEntity WHERE Barcode = @stepInput
BEGIN TRY
	IF ISNULL(@BarcodeIsOnhold, 0) = 1
	BEGIN
		RAISERROR('Barcode %s is on hold. You cannot transfer it', 16, 1, @stepInput)
	END
	INSERT INTO @Output
	SELECT 'DestinationLocation', @DestinationLocation
	UNION ALL
	SELECT 'Qty', CONVERT(VARCHAR, @TrackingEntityQty)
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
