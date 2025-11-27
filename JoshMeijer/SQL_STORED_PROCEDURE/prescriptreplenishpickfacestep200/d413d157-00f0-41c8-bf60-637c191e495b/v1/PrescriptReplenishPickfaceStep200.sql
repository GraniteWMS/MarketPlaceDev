CREATE PROCEDURE [dbo].[PrescriptReplenishPickfaceStep200] (
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




DECLARE @MasterItem_id bigint
DECLARE @FromBarcode varchar(50)
DECLARE @Location varchar(50)
DECLARE @Location_id bigint
DECLARE @PickfaceBarcode varchar(50)
DECLARE @UserName varchar(50)

SELECT @FromBarcode = [Value] FROM @input WHERE [Name] = 'FromTrackingEntity'
SELECT @MasterItem_id = MasterItem_id FROM TrackingEntity WHERE Barcode = @FromBarcode
SELECT @Location = [Value] FROM @input WHERE [Name] = 'Location'
SELECT @Location_id = ISNULL(ID, 0) FROM [Location] WHERE Barcode = @Location
SELECT @UserName = [Value] FROM @input WHERE [Name] = 'User'

IF @Location_id = 0
BEGIN
	SELECT @Location_id  = ID FROM [Location] WHERE [Name] = @Location
END

SELECT TOP 1 @PickfaceBarcode = Barcode 
FROM TrackingEntity 
WHERE MasterItem_id = @MasterItem_id AND Location_id = @Location_id AND InStock = 1


DECLARE @userID bigint
DECLARE @toLocationBarcode nvarchar(50)
DECLARE @fromTrackingentityBarcode nvarchar(50)
DECLARE @toTrackingentityBarcode nvarchar(50)
DECLARE @qty numeric(19,4)
DECLARE @comment nvarchar(50)
DECLARE @reference nvarchar(50)
DECLARE @integrationReference nvarchar(50)
DECLARE @processName nvarchar(50)
DECLARE @responseCode int
DECLARE @responseJSON nvarchar(max)
DECLARE @barcode nvarchar(max)

SELECT @userID = ID FROM Users WHERE [Name] = @UserName
SELECT @fromTrackingentityBarcode = @FromBarcode
SELECT @toLocationBarcode = @Location 
SELECT @toTrackingentityBarcode = @PickfaceBarcode
SELECT @qty = [Value] FROM @input WHERE [Name] = 'Qty'
SELECT @processName = 'REPLENISH_PICKFACE'

EXECUTE [dbo].[clr_Replenish] 
   @userID
  ,@toLocationBarcode
  ,@fromTrackingentityBarcode
  ,@toTrackingentityBarcode
  ,@qty
  ,@comment
  ,@reference
  ,@integrationReference
  ,@processName
  ,@responseCode OUTPUT
  ,@responseJSON OUTPUT
  ,@barcode OUTPUT

IF @responseCode = 200
BEGIN
	SELECT @valid = 1
	SELECT @message = 'Pickface replenish successful'
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = @responseJSON
END





	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
