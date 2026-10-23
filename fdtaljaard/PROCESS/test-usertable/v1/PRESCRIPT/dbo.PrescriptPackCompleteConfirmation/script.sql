
CREATE PROCEDURE [dbo].[PrescriptPackCompleteConfirmation] (
   @input dbo.ScriptInputParameters READONLY
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @Document_id BIGINT
DECLARE @valid bit = 0
DECLARE @message varchar(MAX) = ''
DECLARE @user varchar(30) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @stepInput varchar(MAX) = (SELECT UPPER(Value) FROM @input WHERE Name = 'StepInput') 
DECLARE @Printer varchar(50) = (SELECT UPPER(Value) FROM @input WHERE Name = 'PrinterName') 
DECLARE @sReportPrinterName varchar(max)
DECLARE @Document varchar(50) = (SELECT UPPER(Value) FROM @input WHERE Name = 'Document') 
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
IF @stepInput = 'YES' OR @stepInput = 'Y'
BEGIN
	SELECT @Document_id = ID FROM Document WHERE Number = @Document
	
	INSERT INTO custom_DocumentTrackingLog (Document,[Version],TrackingStatus,[User],ActivityDate,Comment)
	SELECT @Document,1,'Sent to Shipping',@user,getdate(),'Packing Complete -Sent to Shipping'
	UPDATE Document SET [Status] = 'SHIPPING' WHERE ID = @Document_id
	EXEC [dbo].[Utility_PrintPackingList] @Document, @sReportPrinterName
	
	
	SELECT @valid = 1
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
