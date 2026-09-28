
CREATE PROCEDURE [dbo].[Prescript_CCF_PACKPALLET_Step200] (
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
DECLARE @CarryingEntity varchar(50) = (SELECT Value FROM @input WHERE Name = 'Palletbarcode')
DECLARE @User varchar(50) = (SELECT [Value] FROM @input WHERE Name = 'User')
DECLARE @userID bigint
SELECT @userID = ID FROM Users WHERe Name = @User
IF isnull(@userID,0) = 0 SELECT @userID = 3
DECLARE @barcode nvarchar(max)  = @CarryingEntity
DECLARE @barcodes nvarchar(max) = NULL
DECLARE @printerName nvarchar(max) =  (SELECT RTRIM(UPPER(Value)) FROM @input WHERE Name = 'PrinterName')
IF isnull(@printerName ,'') = ''
	SELECT @printerName = 'Z1'
DECLARE @type nvarchar(max) = 'PALLET'
DECLARE @labelName nvarchar(max) = 'Pallet.btw'
DECLARE @numberOfLabels int = 1
DECLARE @success bit
EXEC dbo.clr_PrintLabel
	@barcode
	,@barcodes
	,@labelName
	,@numberOfLabels
	,@printerName
	,@type
	,@userID
	,@success
	,@message
IF @success = 1
	SELECT @message = CONCAT('Printed to:',@printerName,'--',@message)
IF @success = 0
	SELECT @message = CONCAT('CLR Failed',@printerName,'--',isnull(@message,'FAILED'))
INSERT INTO custom_LogMessages([message])
SELECT CONCAT('--',@CarryingEntity,'--',isnull(@message,'FAILED'))
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
