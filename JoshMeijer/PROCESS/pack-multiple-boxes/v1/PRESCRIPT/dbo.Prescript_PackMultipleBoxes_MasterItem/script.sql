CREATE PROCEDURE [dbo].[Prescript_PackMultipleBoxes_MasterItem] (
   @input dbo.ScriptInputParameters READONLY
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE @user varchar(30) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @stepInput varchar(MAX) = (SELECT UPPER(Value) FROM @input WHERE Name = 'StepInput') 
DECLARE @Printer varchar(50) = (SELECT Value FROM @input WHERE Name = 'PrinterName')
DECLARE @sReportPrinterName varchar(max)
DECLARE @Document varchar(50) = (SELECT UPPER(Value) FROM @input WHERE Name = 'Document') 
DECLARE @MasterItemCode varchar(max)
DECLARE @MasterItem_id Bigint
DECLARE @Document_id BIGINT
DECLARE	@reportPath [nvarchar](max)
DECLARE @printerName [nvarchar](max)
DECLARE @parameters [nvarchar](max)
DECLARE @responseCode [int]
DECLARE @responseJSON [nvarchar](max)
DECLARE @PackingListType bit
IF UPPER(@stepInput) = 'PACK COMPLETE'
BEGIN
	SELECT @sReportPrinterName = Value FROM SystemStaticData WHERE [Key] = 'PackingListPrinterStation4'  
	IF @Printer = '1'
		SELECT @sReportPrinterName = Value FROM SystemStaticData WHERE [Key] = 'PackingListPrinterStation1'
	IF @Printer = '2'
		SELECT @sReportPrinterName = Value FROM SystemStaticData WHERE [Key] = 'PackingListPrinterStation2'
	IF @Printer = '3'
		SELECT @sReportPrinterName = Value FROM SystemStaticData WHERE [Key] = 'PackingListPrinterStation3'
	IF @Printer = '4'
		SELECT @sReportPrinterName = Value FROM SystemStaticData WHERE [Key] = 'PackingListPrinterStation4'
	IF @Printer = '5'
		SELECT @sReportPrinterName = Value FROM SystemStaticData WHERE [Key] = 'PackingListPrinterStation5'
	IF @Printer = '6'
		SELECT @sReportPrinterName = Value FROM SystemStaticData WHERE [Key] = 'PackingListPrinterStation6'
	IF @Printer = '7'
		SELECT @sReportPrinterName = Value FROM SystemStaticData WHERE [Key] = 'PackingListPrinterStation7'
	INSERT INTO custom_DocumentTrackingLog (Document,[Version],TrackingStatus,[User],ActivityDate,Comment)
	SELECT @Document,1,'Sent to Shipping',@user,getdate(),'Packing Complete -Sent to Shipping'
	EXEC dbo.Utility_UpdateDocumentStatus @Document, 'SHIPPING', @user
	SELECT @valid = 0
	SELECT @message = 'Order Changed to Shipping and Packing Slip Queued to Printer' 
	SELECT @stepInput = ''
END
ELSE
BEGIN
	SET @MasterItemCode = @stepInput
	IF @stepInput IN (SELECT Code FROM MasterItemAlias_View)
	BEGIN
		SELECT TOP 1 @MasterItemCode = MI.Code FROM MasterItemAlias_View MIAV INNER JOIN MasterItem MI ON MIAV.MasterItem_id = MI.ID 
		WHERE MIAV.Code = @stepInput
	END
	
	IF EXISTS(SELECT DD.ID FROM DocumentDetail DD INNER JOIN MasterItem MI ON DD.Item_id = MI.ID INNER JOIN Document D ON DD.Document_id = D.ID WHERE D.Number = @Document AND MI.Code = @MasterItemCode)
	BEGIN
		SET @valid = 1
		SET @message = @MasterItemCode
	END
	ELSE
	BEGIN
		SET @valid = 0
		SET @message = CONCAT(@MasterItemCode, ' was not found on document.')
	END
     
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
