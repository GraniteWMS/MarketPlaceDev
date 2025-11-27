CREATE PROCEDURE [dbo].[PrescriptPrintPickslipConfirmation] (
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

DECLARE @ResponseCode int
DECLARE @ResponseJson varchar(max)
DECLARE @reportPath varchar(50) = N'/Pick Slip - by Code Location'
DECLARE @printerName varchar(50)
	SELECT @printerName = Value FROM @input WHERE Name = 'Printer'
DECLARE @Parameters varchar(200) = ''

DECLARE @Document varchar(30)
	SELECT @Document = Value FROM @input WHERE Name = 'Document'

IF @stepInput = 'Yes'
	BEGIN
		IF NOT EXISTS(SELECT * FROM Document WHERE Number = @Document)
			BEGIN
				SELECT @valid = 0, @message = 'Document does not exist'
			END
		ELSE
			BEGIN
				SELECT @Parameters = dbo.report_AddReportParameter(@Parameters, 'DocumentNumber', @Document)

				EXEC [dbo].[clr_ReportPrint]
						@reportPath
						,@printerName
						,@parameters
						,@responseCode OUTPUT
						,@responseJSON OUTPUT

				IF (@ResponseCode <> 200)
					BEGIN
						SELECT @valid = 0, @message = @ResponseJson
					END
				ELSE
					BEGIN
						SELECT @valid = 1, @message = @ResponseJson
					END
			END
	END





	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
