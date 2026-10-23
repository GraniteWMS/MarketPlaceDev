CREATE PROCEDURE [dbo].[PrescriptGenerateLoadSheetLoadSheet] (
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
DECLARE @Type varchar(20)
DECLARE @EmailList varchar(max)
DECLARE @parameters nvarchar(max)
DECLARE @reportAttachments nvarchar(max)
DECLARE @LoadSheet varchar(max)
DECLARE @reportPath varchar(50)
DECLARE @printerName varchar(50) 
DECLARE @responseCode int
DECLARE @responseJSON nvarchar(max)
SELECT @Type = Value FROM @input WHERE Name = 'Type'
IF @Type = 'EMAIL'
BEGIN
	SELECT @EmailList = [Value]
	FROM SystemStaticData
	WHERE [Group] = 'Email'
	  AND [Key] = 'LoadSheet'
	
	SELECT @valid = 1
	SELECT @message = CONCAT('Email selected. Email list :',@EmailList)
	
	SET @LoadSheet = dbo.email_CreateReportAttachment('/Documents/LoadSheet', 'PDF')		
	SET @LoadSheet = dbo.email_AddReportParameter(@LoadSheet, 'Reference', @stepInput)		
	SET @reportAttachments = dbo.email_AddReportAttachment(@reportAttachments, @LoadSheet)
	EXECUTE [dbo].[clr_SimpleEmail] 
	   @stepInput							
	  ,'Please see attached Load Sheet'		
	  ,@EmailList							
	  ,NULL									
	  ,NULL									
	  ,@reportAttachments
	  ,NULL									
	  ,NULL									
	  ,@responseCode OUTPUT
	  ,@responseJSON OUTPUT
	IF @responseCode = 200
	BEGIN
		SELECT @valid = 1
		SELECT @message = 'Email Queued.'
	END
	ELSE
	BEGIN
		SELECT @valid = 0
		SELECT @message = 'Failed to queue email'
	END
END
ELSE IF @Type = 'PRINT'
BEGIN
	SELECT @printerName = [Value]
	FROM SystemStaticData
	WHERE [Group] = 'Printer'
	  AND [Key] = 'DocumentPrinter'
	SELECT @parameters = dbo.report_AddReportParameter(@parameters,'Reference',@stepInput)
	SELECT @reportPath = '/Documents/LoadSheet'
	EXEC [dbo].[clr_ReportPrint]
		@reportPath
		,@printerName
		,@parameters
		,@responseCode OUTPUT
		,@responseJSON OUTPUT
	
	IF @responseCode = 200
	BEGIN
		SELECT @valid = 1
		SELECT @message = 'Print Queued.'
	END
	ELSE
	BEGIN
		SELECT @valid = 0
		SELECT @message = 'Failed to queue print job'
	END
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
