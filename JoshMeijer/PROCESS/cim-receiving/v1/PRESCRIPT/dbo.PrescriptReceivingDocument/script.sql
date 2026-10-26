CREATE PROCEDURE [dbo].[PrescriptReceivingDocument] (
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
DECLARE @Document varchar(50) = @stepInput
DECLARE @DocumentID bigint
DECLARE @Location varchar(30)
DECLARE @ERPLocation varchar(30)
IF EXISTS (SELECT 1 FROM Document WHERE Number = CONCAT('P', @Document))
BEGIN
	SELECT @stepInput = CONCAT('P', @Document)
	SELECT @DocumentID = ID FROM Document WHERE Number = @stepInput
	SELECT @Location = Value FROM @input WHERE Name = 'Location'
	SELECT @ERPLocation = ERPlocation FROM Location WHERE Barcode = @Location
	IF EXISTS (SELECT 1 FROM DocumentDetail WHERE Document_id = @DocumentID AND ToLocation = @ERPLocation AND Qty > ActionQty AND Completed = 0)
	BEGIN
		SELECT @valid = 1
		SELECT @message = ''
	END
	ELSE
	BEGIN
		SELECT @valid = 0
		SELECT @message = CONCAT('No stock left to receive for ', @ERPLocation)
	END
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = CONCAT(@Document, ' is not a valid RECEIVING document')
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
