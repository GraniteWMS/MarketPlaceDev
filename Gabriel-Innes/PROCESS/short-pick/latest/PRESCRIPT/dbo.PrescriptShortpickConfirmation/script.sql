CREATE PROCEDURE [dbo].[PrescriptShortpickConfirmation] (
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
DECLARE @DocumentNumber varchar(30)
	SELECT @DocumentNumber = Value FROM @input WHERE Name = 'Document'
DECLARE @DocumentId bigint 
	SELECT @DocumentId = ID FROM Document WHERE Number = @DocumentNumber
DECLARE @Line varchar(30)
	SELECT @Line = Value FROM @input WHERE Name = 'Line'
DECLARE @Reason varchar(50)
	SELECT @Reason = Value FROM @input WHERE Name = 'Reason'

IF(@stepInput = 'Yes')
	BEGIN
		
		UPDATE DocumentDetail
		SET Comment = @Reason,
		    Completed = 1
		WHERE ID = CONVERT(bigint, @Line)

		IF NOT EXISTS (SELECT * FROM DocumentDetail WHERE Document_id = @DocumentId AND Completed = 0)
			UPDATE Document SET Status = 'COMPLETE' WHERE ID = @DocumentId

		SELECT @valid = 1                  
		SELECT @message = ''  
	END
ELSE
	BEGIN
		SELECT @valid = 1                  
		SELECT @message = 'Update cancelled' 
	END

INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
