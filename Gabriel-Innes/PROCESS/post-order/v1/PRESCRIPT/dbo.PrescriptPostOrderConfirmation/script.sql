CREATE PROCEDURE [dbo].[PrescriptPostOrderConfirmation] (
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


DECLARE @PostedStatus varchar(30)
	SELECT @PostedStatus = Value FROM SystemStaticData WHERE [Key] = 'PostedStatus'
DECLARE @User varchar(30)
	SELECT @User = Value FROM @input WHERE Name = 'User'
DECLARE @Document varchar(30)
	SELECT @Document = Value FROM @input WHERE Name = 'Document'
DECLARE @DocumentId bigint
	SELECT @DocumentId = ID FROM Document WHERE Number = @Document AND Type = 'ORDER' 


IF (@stepInput = 'Yes')
	BEGIN
		IF (ISNULL(@DocumentId, 0) = 0)
			BEGIN
				SELECT @valid = 0, @message = CONCAT(@Document, ' does not exist')
			END
		ELSE IF EXISTS(SELECT * FROM DocumentDetail WHERE Document_id = @DocumentId AND ActionQty <> PackedQty)
			BEGIN
				SELECT @valid = 0, @message = 'Pick and pack quantities do not match.'
			END
		ELSE IF ((SELECT Status FROM Document WHERE ID = @DocumentId) = @PostedStatus)
			BEGIN
				SELECT @valid = 0, @message = CONCAT(@Document, ' already is status ', @PostedStatus)
			END
		ELSE 
			BEGIN
		
				INSERT INTO Audit([User], RecordID, RecordVersion, Application, TableName, ChangeType, ColumnName, PreviousValue, NewValue)
				SELECT @User, ID, (Version + 1), 'Webservice', 'Document', 'UPDATE', 'Status', Status, @PostedStatus
				FROM Document

				UPDATE Document
				SET Status = @PostedStatus
				WHERE Document.ID = @DocumentId

				SELECT @valid = 1, @message = CONCAT(@Document, ' status changed to ', @PostedStatus)

			END
	END




	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
