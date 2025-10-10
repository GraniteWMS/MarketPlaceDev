CREATE PROCEDURE [dbo].[Prescript_Example_ExportSsrsReport] (
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

DECLARE @reportPath varchar(50)
DECLARE @fileDestinationPath varchar(50)
DECLARE @fileType varchar(50) 
DECLARE @parameters varchar(200)
DECLARE @responseCode int
DECLARE @responseJson varchar(max)

SELECT @reportPath = N'/Pick Slip - Per Cage'
SELECT @fileDestinationPath = 'D:\\Granite WMS\\V5 Demo\\PickSlip.pdf'
SELECT @fileType = 'PDF'

SELECT @parameters = dbo.report_AddReportParameter(@parameters, 'DocumentNumber', 'STV-AVO-000001')
SELECT @parameters = dbo.report_AddReportParameter(@parameters, 'Cage', 'CAGE D')

EXEC [dbo].[clr_ReportExportToFile]
	@reportPath
	,@fileDestinationPath
	,@fileType
	,@parameters
	,@responseCode OUTPUT
	,@responseJson OUTPUT

SELECT @responseCode, @responseJson

IF @responseCode = 200
BEGIN
	SELECT @valid = 1
	SELECT @message = 'Report exported successfully'
END	
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = @responseJson
END

INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput

SELECT * FROM @Output


