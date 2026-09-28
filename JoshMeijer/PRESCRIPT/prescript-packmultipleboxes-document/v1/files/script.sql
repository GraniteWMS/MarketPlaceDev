CREATE PROCEDURE [dbo].[Prescript_PackMultipleBoxes_Document] (
   @input dbo.ScriptInputParameters READONLY
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @sql varchar(max)
DECLARE @html varchar(max)
DECLARE @orderby varchar(max)
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE @user varchar(30) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @stepInput varchar(MAX) = (SELECT UPPER(Value) FROM @input WHERE Name = 'StepInput') 
DECLARE @sOrderNumber varchar(50) = RTRIM(@stepInput)
DECLARE @Printer varchar(50) = (SELECT Value FROM @input WHERE Name = 'PrinterName')
IF isnull(@Printer,'') = ''
BEGIN
	SELECT @message = 'No PRINTER is ENTERED -please logout and enter a Printer'
	SELECT @valid = 0
END
ELSE
BEGIN
	DECLARE @Document_id BIGINT
	SELECT @Document_id = ID FROM Document WHERE Number = @sOrderNumber
	IF isnull(@Document_id,0) = 0
	BEGIN
		SELECT @valid = 0
		SELECT @message = 'Document:' + @stepInput + ' Not Found:'
	END
	ELSE
	BEGIN
		
		INSERT INTO custom_DocumentTrackingLog (Document,[Version],TrackingStatus,[User],ActivityDate,Comment)
		SELECT @sOrderNumber,1,'START CHECKING',@user,getdate(),'Starting Checking and Packing Process'
		EXEC dbo.Utility_UpdateDocumentStatus @sOrderNumber, 'PACKING', @user
		UPDATE DocumentDetail SET ActionQty = Qty WHERE Document_id = @Document_id 
	END
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
