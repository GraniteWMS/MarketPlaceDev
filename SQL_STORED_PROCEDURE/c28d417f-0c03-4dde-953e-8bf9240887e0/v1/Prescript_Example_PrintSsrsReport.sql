CREATE PROCEDURE [dbo].[Prescript_Example_PrintSsrsReport] (
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
DECLARE @printerName varchar(50) 
DECLARE @parameters varchar(200)
DECLARE @responseCode int
DECLARE @responseJson varchar(max)

SELECT @reportPath = '/Pick Slip - Per Cage'
SELECT @printerName = 'TestPrinter'

SELECT @parameters = dbo.report_AddReportParameter(@parameters, 'DocumentNumber', 'STV-AVO-000001')
SELECT @parameters = dbo.report_AddReportParameter(@parameters, 'Cage', 'CAGE D')

EXEC [dbo].[clr_ReportPrint]
	@reportPath
	,@printerName
	,@parameters
	,@responseCode OUTPUT
	,@responseJSON OUTPUT

IF @responseCode = 200
BEGIN
	SELECT @valid = 1
	SELECT @message = 'Report printed successfully'
END	
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = @responseJSON
END

INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput

SELECT * FROM @Output


