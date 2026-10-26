CREATE PROCEDURE  [dbo].[Prescript_PrintMasterItemLabels_Confirmation] (
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
DECLARE @userName varchar(30)
SELECT @stepInput = [Value] FROM @input WHERE [Name] = 'StepInput'
SELECT @userName = [Value] FROM @input WHERE [Name] = 'User'
DECLARE @userID bigint = (SELECT  ID FROM Users WHERE [Name] = @userName)
DECLARE @success int
DECLARE @MasterItem varchar(50) = (SELECT Value FROM @input WHERE Name = 'MasterItem')
DECLARE @numberOfLabels int = (SELECT Value FROM @Input WHERE Name = 'NumberOfLabels')
DECLARE @barcode nvarchar(max)
DECLARE @barcodes nvarchar(max)
DECLARE @labelName nvarchar(500) = 'MasterItem.zpl'
DECLARE @printerName nvarchar(50) = (SELECT Value FROM @Input WHERE Name = 'PrinterName')
DECLARE @type nvarchar(50) = 'MASTERITEM'
BEGIN TRY
	IF @stepInput NOT IN  ('Y', 'YES')
		RAISERROR('Confirmation declined',16,1)
	SELECT @barcode = @MasterItem
	SELECT @barcodes = NULL
	
	EXECUTE [dbo].[clr_PrintLabel] 
		@barcode
		,@barcodes
		,@labelName
		,@numberOfLabels
		,@printerName
		,@type
		,@userID
		,@success OUTPUT
		,@message OUTPUT
	IF @success = 0
		RAISERROR('The Print Instruction failed (%s)',16,1,@message)
	SELECT @message = 'Print sent to Label Printer'
	SELECT @valid = 1
END TRY
BEGIN CATCH
	SELECT @Valid = 0, @message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
