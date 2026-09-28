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
DECLARE @stepInput varchar(MAX) = (SELECT UPPER(Value) FROM @input WHERE Name = 'StepInput') 
DECLARE @DocumentNumber varchar(50) =(SELECT UPPER(Value) FROM @input WHERE Name = 'Document') 
DECLARE @printerName varchar(200) = 'Fenzi Main'
DECLARE @copies int = 1
DECLARE @Comment varchar(100) = (SELECT [Value] FROM @input WHERE Name = 'Comment')
DECLARE @DocumentID BIGINT
DECLARE @IntegrationReference varchar(50)
DECLARE @subject nvarchar(max)
DECLARE @templateName nvarchar(max)
DECLARE @templateParameters nvarchar(max)
DECLARE @toEmailAddresses nvarchar(max)
DECLARE @ccEmailAddresses nvarchar(max)
DECLARE @bccEmailAddresses nvarchar(max)
DECLARE @reportAttachments nvarchar(max)
DECLARE @excelAttachments nvarchar(max)
DECLARE @fileAttachments nvarchar(max)
DECLARE @success int
DECLARE @PickingReport varchar(max)
DECLARE @TradingPartnerCode varchar(30)
BEGIN TRY
SELECT @TradingPartnerCode=TradingPartnerCode FROM Document WHERE Number = @DocumentNumber
SELECT @DocumentID = ID FROM Document WHERE Number = @DocumentNumber
SELECT TOP 1 @IntegrationReference = IntegrationReference FROM [Transaction]
WHERE Document_id = @DocumentID AND [Type] = 'PICK' 
ORDER BY ID DESC		
	
INSERT INTO custom_DocumentTrackingLog (Document,[Version],TrackingStatus,[User],ActivityDate,Comment,Process,AdditionalData)
SELECT @DocumentNumber,1,'CHECKED',@user,getdate(),''  , 'CHECK-PICKINGPOST',@Comment
INSERT INTO custom_DocumentTrackingLog (Document,[Version],TrackingStatus,[User],ActivityDate,Comment,IntegrationReference,Process)
SELECT @DocumentNumber,1,'PickingPost',@user,getdate(),'Post Document Complete',@IntegrationReference, @process
SET @PickingReport = dbo.email_CreateReportAttachment('/Document/Loadsheet', 'PDF')
SET @PickingReport = dbo.email_AddReportParameter(@PickingReport, 'DocumentNumber', @DocumentNumber)
SET @PickingReport = dbo.email_AddReportParameter(@PickingReport, 'Shipment', @IntegrationReference)
SET @reportAttachments = dbo.email_AddReportAttachment(@reportAttachments, @PickingReport)
SET @subject = 'Loadsheet for Document Number #' + @DocumentNumber   
DECLARE @reportPath varchar(100)
DECLARE @parameters varchar(250) 
SELECT @reportPath = '/Document/Loadsheet'
SELECT @parameters = dbo.report_AddReportParameter(@parameters, 'DocumentNumber', @DocumentNumber)
SELECT @parameters = dbo.report_AddReportParameter(@parameters, 'Shipment', @IntegrationReference)
EXECUTE [dbo].[clr_ReportPrint]
	@reportPath
	,@printerName
	,@parameters
	,@copies
	,@success OUTPUT
	,@message OUTPUT
SELECT @message
SELECT @success
IF @success <> 1
		RAISERROR(N'%s', 16, 1, @message)
	
EXECUTE [dbo].[clr_ReportPrint]
	@reportPath
	,@printerName
	,@parameters
	,@copies
	,@success OUTPUT
	,@message OUTPUT
IF @success <> 1
		RAISERROR(N'%s', 16, 1, @message)
	
	
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
