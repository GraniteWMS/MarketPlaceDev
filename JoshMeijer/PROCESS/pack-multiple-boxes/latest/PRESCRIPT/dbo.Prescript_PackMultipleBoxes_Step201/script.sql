CREATE PROCEDURE [dbo].[Prescript_PackMultipleBoxes_Step201] (
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
DECLARE @user varchar(30) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @NumberOfBoxes bigint = (SELECT Value FROM @input WHERE Name = 'NoOfBoxes')
DECLARE @stepInput varchar(MAX) = (SELECT Value FROM @input WHERE Name = 'StepInput') 
DECLARE @ShouldPrintLabels bit
DECLARE @CurrentBoxNumber varchar(50)
DECLARE @responseCode [int]
DECLARE	@responseJSON [nvarchar](max)
DECLARE	@reportPath [nvarchar](max)
DECLARE @printerName [nvarchar](max) = (SELECT Value FROM @input WHERE Name = 'PrinterName') 
DECLARE @parameters [nvarchar](max)
DECLARE @UserID bigint
DECLARE @Length bigint
DECLARE @NextBarcode bigint
DECLARE @Prefix varchar(10)
DECLARE @Min bigint
DECLARE @Max bigint
DECLARE @Counter bigint
SELECT @ShouldPrintLabels = CASE (SELECT Value FROM @input WHERE Name = 'PrintLabels') WHEN 'YES' THEN 1 ELSE 0 END
SELECT @UserID = ID FROM Users WHERE [Name] = @user
DECLARE @NewBoxes TABLE
(
ID bigint identity(1, 1),
BoxNumber varchar(50)
)
INSERT INTO @NewBoxes (BoxNumber)
SELECT TOP (@NumberOfBoxes) Barcode 
FROM CarryingEntity
WHERE AuditUser = @user
ORDER BY AuditDate DESC
SELECT @Min = MIN(ID), @Max = MAX(ID), @Counter = MIN(ID) FROM @NewBoxes
IF @ShouldPrintLabels = 1
BEGIN
	SET @reportPath = '/BoxLabel'
	WHILE @Counter >= @Min AND @Counter <= @Max
	BEGIN
		SELECT @parameters = ''
		SELECT @CurrentBoxNumber = BoxNumber FROM @NewBoxes WHERE ID = @Counter
		SELECT @parameters = [dbo].[report_AddReportParameter] (@parameters, 'BoxNumber', @CurrentBoxNumber)
		EXEC [dbo].[clr_ReportPrint]
		@reportPath,
		@printerName,
		@parameters,
		@responseCode OUTPUT,
		@responseJSON OUTPUT
		SET @Counter = @Counter + 1
	END
END
SET @valid = 1
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
