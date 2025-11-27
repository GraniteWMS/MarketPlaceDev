CREATE PROCEDURE [dbo].[DELIVERY_ARRIVAL_PODocument] (
   @input dbo.ScriptInputParameters READONLY
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @Process varchar(50) = 'DELIVERY_ARRIVAL'
DECLARE @TrackingStatus varchar(50) = 'DELIVERY RECORDED'
DECLARE @IntegrationQueueStatus varchar(20) = 'ENTERED'
DECLARE @IntegrationDocumentType varchar(20) = 'RECEIVING'
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE @user varchar(30) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @stepInput varchar(MAX) = (SELECT UPPER(Value) FROM @input WHERE Name = 'StepInput') 
DECLARE @Carrier varchar(50) = (SELECT UPPER(Value) FROM @input WHERE Name = 'Carrier') 
DECLARE @VehicleReg varchar(50) = (SELECT UPPER(Value) FROM @input WHERE Name = 'VehicleReg') 
DECLARE @Driver varchar(50) = (SELECT UPPER(Value) FROM @input WHERE Name = 'Driver') 
DECLARE @Reference varchar(100) = (SELECT UPPER(Value) FROM @input WHERE Name = 'Reference') 
DECLARE @IntegrationReference varchar(250)
DECLARE @AdditionalData varchar(250)
DECLARE @ERP_id varchar(50)
DECLARE @Document varchar(50) = RTRIM(@stepInput)
DECLARE @Document_id BIGINT
SELECT @Document_id = ID FROM Document WHERE Number = @Document and Document.[Type] = 'RECEIVING'
IF isnull(@Document_id,0) = 0
BEGIN	
	
	SELECT @IntegrationReference = 'Document not in Granite' 
	
	
	
	--SELECT @ERP_id = PORHSEQ FROM [SAMINC].dbo.[POPORH1] WHERE PONUMBER COLLATE DATABASE_DEFAULT = @Document COLLATE DATABASE_DEFAULT 
	
	
	SELECT @IntegrationReference = CONVERT(varchar(50),isnull(@ERP_id,'Document not in Granite or ERP' ))
END	
IF isnull(@ERP_id,0) >0		
	INSERT INTO IntegrationDocumentQueue (ERP_id, DocumentNumber, DocumentType, [Status], LastUpdateDateTime)
	SELECT @ERP_id,@Document,@IntegrationDocumentType,@IntegrationQueueStatus,getdate()
	
INSERT INTO custom_DocumentTrackingLog (Document,[Version],TrackingStatus,[User],ActivityDate,Comment,DocumentReference,IntegrationReference,Process,AdditionalData)
SELECT @Document,1,@TrackingStatus,@user,getdate(),CONCAT('Carrier:',isnull(@Carrier,''),' Vehicle:',isnull(@VehicleReg,''),' Driver:',isnull(@Driver,'')) as Comment,@Reference,@IntegrationReference,@Process,@AdditionalData
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
