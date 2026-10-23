CREATE PROCEDURE [dbo].[Prescript_3PL_LoadCompleteConfirmation] (
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
DECLARE @stepInput varchar(MAX) 
DECLARE @expectedDate DATETIME
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @Document varchar(50) = (SELECT Value FROM @input WHERE Name = 'Document' )
DECLARE @User varchar(50) = (SELECT Value from @input WHERE Name = 'User')
DECLARE @Document_id bigint
DECLARE @Version int
DECLARE @PreviousStatus varchar(30)
	
DECLARE @reportPath varchar(50)
DECLARE @printerName varchar(50) 
DECLARE @parameters varchar(200)
DECLARE @responseCode int
DECLARE @responseJSON varchar(max)
SELECT @reportPath = '/Loadsheet'
SELECT @printerName = 'HPI04BCE7 (HP Color LaserJet Pro MFP 3303)'
SELECT @parameters = dbo.report_AddReportParameter(@parameters, 'DocumentNumber', @Document)
EXEC [dbo].[clr_ReportPrint]
    @reportPath
    ,@printerName
    ,@parameters
    ,@responseCode OUTPUT
    ,@responseJSON OUTPUT
	
DECLARE @subject nvarchar(max)
DECLARE @templateName nvarchar(max)
DECLARE @templateParameters nvarchar(max)
DECLARE @toEmailAddresses nvarchar(max)
DECLARE @ccEmailAddresses nvarchar(max)
DECLARE @bccEmailAddresses nvarchar(max)
DECLARE @reportAttachments nvarchar(max)
DECLARE @excelAttachments nvarchar(max)
DECLARE @fileAttachments nvarchar(max) 
DECLARE @LoadsheetReport varchar(max)
DECLARE @TradingPartnerCode varchar(30)
SELECT @TradingPartnerCode=TradingPartnerCode FROM Document WHERE Number = @Document
SET @templateName = 'Email_Loadsheet' 
SELECT @templateParameters = dbo.email_AddTemplateParameter(@templateParameters, 'DocumentNumber', @Document)
SET @LoadsheetReport = dbo.email_CreateReportAttachment('/Loadsheet', 'PDF')
SET @LoadsheetReport = dbo.email_AddReportParameter(@LoadsheetReport, 'DocumentNumber', @Document)
SET @reportAttachments = dbo.email_AddReportAttachment(@reportAttachments, @LoadsheetReport)
SET @subject = 'Loadsheet for Document Number #' + @Document 
IF @TradingPartnerCode = 'JWN'
	SET @toEmailAddresses = 'Toni-Ann.Anderson@avalon3pl.com;Junior.Murray@avalon3pl.com;Kenroy.Ramsay@avalon3pl.com;Brian.Taylor@avalon3pl.com;Shawnette.Harvey@campari.com;KevinSamuel.Richards@campari.com;Chad.Francis@campari.com;Courtney.brooks@campari.com'  
ELSE IF  @TradingPartnerCode = 'NR'
	SET @toEmailAddresses = 'Toni-Ann.Anderson@avalon3pl.com;Junior.Murray@avalon3pl.com;Kenroy.Ramsay@avalon3pl.com;Brian.Taylor@avalon3pl.com;srobinson@monymuskrums.com;mjames@monymuskrums.com'  
ELSE IF @TradingPartnerCode = 'GK'
	SET @toEmailAddresses = 'Toni-Ann.Anderson@avalon3pl.com;Junior.Murray@avalon3pl.com;Kenroy.Ramsay@avalon3pl.com;Brian.Taylor@avalon3pl.com;fashaya.johnson@gkco.com;kirk-dale.hutchinson@gkco.com;damian.curate@gkco.com;carlton.beckford@gkco.com;raffic.shaw@gkco.com;edward.findlay@gkco.com'  
ELSE
	SET @toEmailAddresses = 'Toni-Ann.Anderson@avalon3pl.com;Junior.Murray@avalon3pl.com;Kenroy.Ramsay@avalon3pl.com;Brian.Taylor@avalon3pl.com'
SELECT @Document_id = ID, @Version = [Version], @PreviousStatus = [Status] FROM Document WHERE Number = @Document
UPDATE Document SET [Status] = 'COMPLETE', [Version] = [Version]+1, AuditDate = getdate() , AuditUser = @User WHERE Number = @Document
INSERT INTO Audit(AuditDate, AuditTime, [User], RecordID, RecordVersion, Application, TableName, ChangeType, ColumnName, PreviousValue, NewValue)
SELECT getdate(), SUBSTRING(CONVERT(varchar(20),getdate()), 12,8), @user, @Document_id, @Version, 'ProcessApp','Document','UPDATE','Status', @PreviousStatus,'COMPLETE'
INSERT INTO custom_DocumentTrackingLog(Document, [Version], TrackingStatus, [User], ActivityDate, Comment, Process, AdditionalData)
SELECT @Document, @Version+1, 'COMPLETE',@User, getdate(), 'LOADOUT COMPLETE Logged and Email sent','3PL_LoadComplete',@toEmailAddresses
EXECUTE [dbo].[clr_TemplateEmail] 
	   @subject
	  ,@templateName
	  ,@templateParameters
	  ,@toEmailAddresses
	  ,@ccEmailAddresses
	  ,@bccEmailAddresses
	  ,@reportAttachments
	  ,@excelAttachments
	  ,@fileAttachments
	  ,@responseCode OUTPUT
	  ,@responseJSON OUTPUT
SELECT @message = 'Load out Summary sent via email'
SELECT @valid = 1
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
