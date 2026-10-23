CREATE PROCEDURE [dbo].[PrescriptReceivingPostStep200] (
   @input dbo.ScriptInputParameters READONLY
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @process varchar(50) = 'RECEIVINGPOST'
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE @user varchar(30) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @LabelFormat varchar(50) = 'RECEIPTCONFIRMLIVE.BTW'
DECLARE @Printer varchar(50) = (SELECT Value FROM @input WHERE Name = 'PrinterName')
DECLARE @stepInput varchar(MAX) = (SELECT UPPER(Value) FROM @input WHERE Name = 'StepInput') 
DECLARE @DocumentNumber varchar(50) =(SELECT UPPER(Value) FROM @input WHERE Name = 'Document') 
DECLARE @DocumentID BIGINT
DECLARE @IntegrationReference varchar(50)
DECLARE @ERP_RCPNumber varchar(50)
SELECT @DocumentID = ID FROM Document WHERE Number = @DocumentNumber
SELECT TOP 1 @IntegrationReference = IntegrationReference FROM [Transaction]
WHERE Document_id = @DocumentID AND [Type] = 'RECEIVE' 
ORDER BY ID DESC
SELECT TOP(1)* FROM Label_ReceiptSummary
INSERT INTO custom_DocumentTrackingLog (Document,[Version],TrackingStatus,[User],ActivityDate,Comment,IntegrationReference,Process)
SELECT @DocumentNumber,1,'ReceivingPost',@user,getdate(),'Post Document Complete',@IntegrationReference, @process
INSERT INTO LabelPrintQueue (DateQueued, LabelFormat, LabelParameter1,LabelParameter2, QuantityofLabels, Printer, [Status], [User])
SELECT getdate(),@LabelFormat, @DocumentNumber, @IntegrationReference,1,@Printer,'ENTERED',@user
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
