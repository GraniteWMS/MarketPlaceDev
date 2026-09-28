CREATE PROCEDURE [dbo].[PrescriptBlindReceivingDocument] (
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
DECLARE @DocumentNumber varchar (30)
DECLARE @DocumentStatus varchar (30)
SELECT @DocumentNumber = @stepInput
IF EXISTS (SELECT ID FROM Document WHERE Number = @DocumentNumber AND [Type] = 'RECEIVING')
BEGIN
	SELECT @DocumentStatus = [Status] FROM Document WHERE Number = @DocumentNumber
	IF @DocumentStatus <> 'COMPLETE'
	BEGIN
		SELECT @valid = 1
	END
	ELSE
	BEGIN
		SELECT @valid = 0
		SELECT @message = CONCAT(@DocumentNumber, ' has already been marked as COMPLETE')
	END
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message  = CONCAT(@DocumentNumber, ' is not a valid RECEIVING document')
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
