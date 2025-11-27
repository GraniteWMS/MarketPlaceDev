CREATE PROCEDURE [dbo].[PrescriptCompletePickingPostDocument] (
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




SELECT @valid = 1

DECLARE @Document_id bigint

SELECT @Document_id = ISNULL(ID, 0) FROM Document WHERE Number = @stepInput

IF @Document_id > 0
BEGIN
	IF EXISTS(SELECT ID FROM DocumentDetail WHERE Document_id = @Document_id AND ISNULL(ActionQty, 0) <> Qty AND ISNULL(Cancelled, 0) = 0)
	BEGIN
		SELECT @valid = 0
		SELECT @message = 'Document is not complete'
	END
END






	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
