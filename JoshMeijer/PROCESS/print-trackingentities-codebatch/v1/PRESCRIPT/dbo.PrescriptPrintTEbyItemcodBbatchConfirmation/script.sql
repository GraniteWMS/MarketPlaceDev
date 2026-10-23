CREATE PROCEDURE [dbo].[PrescriptPrintTEbyItemcodBbatchConfirmation] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit  =1
DECLARE @message varchar(MAX) = ''
DECLARE @stepInput varchar(MAX)  = (SELECT Value FROM @input WHERE Name = 'StepInput')
DECLARE @MasterItem varchar(50)= (SELECT Value FROM @input WHERE Name = 'MasterItem')
DECLARE @Batch varchar(50) =  (SELECT Value FROM @input WHERE Name = 'Batch')
DECLARE @Printer varchar(50) = (SELECT Value FROM @input WHERE Name = 'Printer')
DECLARE @Location varchar(50) =  (SELECT Value FROM @input WHERE Name = 'Location')
DECLARE @User varchar(50) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @Counter int = 0
DECLARE @barcode nvarchar(50)
DECLARE @barcodes nvarchar(MAX)
DECLARE @labelName nvarchar(500)
DECLARE @numberOfLabels int
DECLARE @printerName nvarchar(50)
DECLARE @type nvarchar(50)
DECLARE @userID bigint
DECLARE @responseCode int
DECLARE @responseJSON nvarchar(max)
DECLARE @NumberEntities int
SELECT @NumberEntities =  COUNT(TE.ID)
								 FROM TrackingEntity TE 
								 INNER JOIN MasterItem MI ON MI.ID = TE.MasterItem_id	
								 INNER JOIN Location L ON TE.Location_id = L.ID
								 WHERE MI.Code = @MasterItem
								 AND L.Barcode = @Location
								   AND TE.Batch = @Batch
								AND TE.Qty > 0 and TE.InStock = 1
SET @barcodes = (SELECT STUFF((SELECT TOP (@NumberEntities) ',' + TE.Barcode
								 FROM TrackingEntity TE 
								 INNER JOIN MasterItem MI ON MI.ID = TE.MasterItem_id	
								  INNER JOIN Location L ON TE.Location_id = L.ID
								 WHERE MI.Code = @MasterItem
								   AND TE.Batch = @Batch
								   AND L.Barcode = @Location
								AND TE.Qty > 0 and TE.InStock = 1
								 ORDER BY TE.ID
								 FOR XML PATH ('')), 1, 1, '')
				)
SELECT @message = @barcodes
SET @type = 'TRACKINGENTITY'
SET @userID = (SELECT ID FROM Users WHERE [Name] = @User)
SET @labelName = 'TrackingEntityQR.zpl'
SET @numberOfLabels = 1
SET @printerName = isnull(@Printer,'Z1')
	
	
	
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
	SELECT @message = 'Labels printed successfully'
	SELECT @Valid = 1
END
ELSE
BEGIN
	SELECT @message = CONCAT('Failed to print labels. ',@responseJSON)
	SELECT @valid = 0
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
