CREATE PROCEDURE [dbo].[PrescriptPostOrderDocument] (
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


DECLARE @Document varchar(30)
	SELECT @Document = @stepInput
DECLARE @DocumentId bigint
	SELECT @DocumentId = ID FROM Document WHERE Number = @Document AND Type = 'ORDER' 

IF (ISNULL(@DocumentId, 0) = 0)
	BEGIN
		SELECT @valid = 0, @message = CONCAT(@Document, ' does not exist')
	END
ELSE IF EXISTS(SELECT * FROM DocumentDetail WHERE Document_id = @DocumentId AND ActionQty <> PackedQty)
	BEGIN
		SELECT @valid = 0, @message = 'Pick and pack quantities do not match.'
	END
ELSE 
	BEGIN
		SELECT @valid = 1
	END




	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
