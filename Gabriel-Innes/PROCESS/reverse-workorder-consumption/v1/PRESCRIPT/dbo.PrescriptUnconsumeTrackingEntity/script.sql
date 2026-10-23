CREATE PROCEDURE [dbo].[PrescriptUnconsumeTrackingEntity] (
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
	SELECT @Document = Value FROM @input WHERE Name = 'Document'
DECLARE @DocumentID bigint
	SELECT @DocumentID = ID FROM Document WHERE Number = @Document

IF EXISTS (	SELECT *
			FROM	[Transaction] 
					INNER JOIN TrackingEntity ON [Transaction].TrackingEntity_id = TrackingEntity.ID 
					INNER JOIN Document ON [Transaction].Document_id = Document.ID 
					INNER JOIN MasterItem ON TrackingEntity.MasterItem_id = MasterItem.ID
			WHERE	[Transaction].Type = 'CONSUME'	
					AND Document.Number = @Document AND TrackingEntity.Barcode = @stepInput)
	BEGIN
		SELECT @valid = 1
	END
ELSE
	BEGIN
		SELECT @valid = 0, @message = CONCAT(@stepInput, ' not consumed against ', @Document)
	END



	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
