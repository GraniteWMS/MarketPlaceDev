CREATE PROCEDURE [dbo].[PrescriptPickingPostStep200] (
   @input dbo.ScriptInputParameters READONLY
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @process varchar(50) = 'PICKINGPOST'
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE @user varchar(30) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @LabelFormat varchar(50) = 'PICKCONFIRM.ZPL'
DECLARE @Printer varchar(50) = (SELECT Value FROM @input WHERE Name = 'PrinterName')
DECLARE @stepInput varchar(MAX) = (SELECT UPPER(Value) FROM @input WHERE Name = 'StepInput') 
DECLARE @DocumentNumber varchar(50) =(SELECT UPPER(Value) FROM @input WHERE Name = 'Document') 
DECLARE @DocumentID BIGINT
DECLARE @IntegrationReference varchar(50)
DECLARE @ERP_SHPNumber varchar(50)
SELECT @DocumentID = ID FROM Document WHERE Number = @DocumentNumber
SELECT TOP 1 @IntegrationReference = IntegrationReference FROM [Transaction]
WHERE Document_id = @DocumentID AND [Type] = 'PICK' 
ORDER BY ID DESC
INSERT INTO custom_DocumentTrackingLog (Document,[Version],TrackingStatus,[User],ActivityDate,Comment,IntegrationReference,Process)
SELECT @DocumentNumber,1,'PickingPost',@user,getdate(),'Post Document Complete',@IntegrationReference, @process
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
