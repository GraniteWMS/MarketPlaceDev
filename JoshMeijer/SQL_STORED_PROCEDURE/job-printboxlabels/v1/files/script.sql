CREATE PROCEDURE [dbo].[Job_PrintBoxLabels]
AS
BEGIN
DECLARE @BoxNumber varchar(100)
DECLARE @Printer varchar(50)
DECLARE	@reportPath [nvarchar](max)
DECLARE @printerName [nvarchar](max)
DECLARE @parameters [nvarchar](max)
DECLARE @success [int]
DECLARE @message [nvarchar](max)
DECLARE @copies smallint = 1
DECLARE @Min bigint
DECLARE @Max bigint
DECLARE @Counter bigint
DECLARE @LabelsToPrint TABLE
(ID bigint identity(1, 1),
BoxNumber varchar(100),
Printer varchar(50))
INSERT INTO @LabelsToPrint(BoxNumber, Printer)
SELECT LabelParameter1, Printer FROM LabelPrintQueue
WHERE LabelFormat = 'SSRSBoxLabel' AND [Status] = 'ENTERED'
SELECT @Min = MIN(ID), @Max = MAX(ID), @Counter = MIN(ID) FROM @LabelsToPrint
SET @reportPath = '/BoxLabel'
WHILE @Counter >= @Min AND @Counter <= @Max
BEGIN
	SELECT @parameters = ''
	SELECT @BoxNumber = BoxNumber, @Printer = Printer FROM @LabelsToPrint WHERE ID = @Counter
	SELECT @parameters = [dbo].[report_AddReportParameter] (@parameters, 'BoxNumber', @BoxNumber)
	EXEC [dbo].[clr_ReportPrint]
	@reportPath,
	'Z4',
	@parameters,
	@copies,
	@success OUTPUT,
	@message OUTPUT
	UPDATE LabelPrintQueue
	SET [Status] = CASE WHEN @success = 1 THEN 'PRINTED' ELSE 'FAILED' END,
	DatePrinted = GETDATE(), ResponseComment = @message
	WHERE LabelFormat = 'SSRSBoxLabel' AND [Status] = 'ENTERED' AND LabelParameter1 = @BoxNumber AND Printer = @Printer
	SET @Counter = @Counter + 1
END
END
