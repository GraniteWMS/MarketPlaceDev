CREATE PROCEDURE [dbo].[PrescriptUnconsumeStep200] (
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
	SELECT @Qty = CONVERT(decimal(19,4), (SELECT Value FROM @input WHERE Name = 'Qty'))
DECLARE @DocumentDetailId bigint
	SELECT @DocumentDetailId = DocumentLine_id	FROM	[Transaction] 
														INNER JOIN TrackingEntity ON [Transaction].TrackingEntity_id = TrackingEntity.ID 
														INNER JOIN Document ON [Transaction].Document_id = Document.ID 
														INNER JOIN MasterItem ON TrackingEntity.MasterItem_id = MasterItem.ID 
														INNER JOIN DocumentDetail ON [Transaction].DocumentLine_id = DocumentDetail.ID
												WHERE	[Transaction].Type = 'CONSUME'	
														AND Document.Number = @Document AND TrackingEntity.Barcode = @TrackingEntity


UPDATE DocumentDetail 
SET ActionQty = (ActionQty - @Qty)
WHERE ID = @DocumentDetailId AND ActionQty >= @Qty

SELECT @valid = 1




	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
