CREATE PROCEDURE [dbo].[PrescriptUnconsumeQty] (
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
DECLARE @TrackingEntity varchar(30)
	SELECT @TrackingEntity = Value FROM @input WHERE Name = 'TrackingEntity'
DECLARE @Qty decimal(19,4)
	SELECT @Qty = CONVERT(decimal(19,4), @stepInput)

IF ( @QTY <= (	SELECT ActionQty
				FROM	[Transaction] 
						INNER JOIN TrackingEntity ON [Transaction].TrackingEntity_id = TrackingEntity.ID 
						INNER JOIN Document ON [Transaction].Document_id = Document.ID 
						INNER JOIN MasterItem ON TrackingEntity.MasterItem_id = MasterItem.ID
				WHERE	[Transaction].Type = 'CONSUME'	
						AND Document.Number = @Document AND TrackingEntity.Barcode = @TrackingEntity)
					
	AND @Qty <= (	SELECT DocumentDetail.ActionQty
					FROM	[Transaction] 
							INNER JOIN TrackingEntity ON [Transaction].TrackingEntity_id = TrackingEntity.ID 
							INNER JOIN Document ON [Transaction].Document_id = Document.ID 
							INNER JOIN MasterItem ON TrackingEntity.MasterItem_id = MasterItem.ID 
							INNER JOIN DocumentDetail ON [Transaction].DocumentLine_id = DocumentDetail.ID
					WHERE	[Transaction].Type = 'CONSUME'	
							AND Document.Number = @Document AND TrackingEntity.Barcode = @TrackingEntity)
				)	
	BEGIN
		SELECT @valid = 1
	END
ELSE
	BEGIN
		SELECT @valid = 0, @message = 'Cannot adjust by more than the consumed qty.';
	END



	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
