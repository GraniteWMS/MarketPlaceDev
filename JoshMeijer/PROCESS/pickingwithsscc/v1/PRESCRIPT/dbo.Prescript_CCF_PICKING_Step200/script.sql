CREATE PROCEDURE [dbo].[Prescript_CCF_PICKING_Step200] (
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
DECLARE @stepInput varchar(MAX) = (SELECT Value FROM @input WHERE Name = 'StepInput')
DECLARE @Document varchar(50) = (SELECT Value FROM @input WHERE Name = 'Document')
DECLARE @PalletBarcode varchar(50) = (SELECT Value FROM @input WHERE Name = 'TrackingEntity')  
DECLARE @printerName nvarchar(max) =  (SELECT RTRIM(UPPER(Value)) FROM @input WHERE Name = 'PrinterName')
IF isnull(@printerName ,'') = ''
	SELECT @printerName = 'Z1'
IF EXISTS(SELECT 1 FROM CarryingEntity WHERE Barcode = @PalletBarcode)
	EXEC dbo.Utility_PrintSSCCLabel @Document, @PalletBarcode, @PrinterName
ELSE
	SELECT @message = 'SSCC label didnt print because the PalletBarcode scanned does not exist'
EXEC dbo.FIFOPickingRecommendation @Document
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
