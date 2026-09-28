CREATE PROCEDURE [dbo].[PrescriptReceiveReturnDocument] (
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
IF NOT EXISTS(SELECT * FROM Document WHERE Type = 'RECEIVING' AND Status IN ('RELEASED', 'ENTERED') AND Number LIKE 'R-%' AND Number = @stepInput) 
	SELECT @valid = 0, @message = @stepInput + ' is not a valid document.'
ELSE
	BEGIN
	UPDATE DocumentDetail
	SET ToLocation = ERPLocation
	FROM Document
	where Number = @stepInput
	and Document_id = Document.ID
	END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
