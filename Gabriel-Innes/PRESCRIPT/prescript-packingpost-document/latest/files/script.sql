CREATE PROCEDURE [dbo].Prescript_PackingPost_Document (
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
DECLARE @Document varchar(100)
    SELECT @Document = Value FROM @input WHERE Name = 'Document'
DECLARE @DocumentId BIGINT
    SELECT @DocumentId = ID FROM Document WHERE Number = @Document
UPDATE [Transaction] 
SET [Transaction].DocumentReference = @stepInput
WHERE Type = 'PACK' AND IntegrationStatus = 0  AND
Document_id = @DocumentId
EXEC    [dbo].[clr_IntegrationPost]
        @transactionID = null,
        @document = @Document,
        @documentReference = null,
        @documents = null,
        @reference = null,
        @transactionType = N'CUSTOMPACK', 
        @processName = N'PACKINGPOST',
        @success = @valid OUTPUT,
        @message = @message OUTPUT
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output