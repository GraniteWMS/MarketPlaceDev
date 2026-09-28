CREATE PROCEDURE [dbo].[Prescript3PL_TransferStagingDocument] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @Document varchar(50) = @stepInput
DECLARE @TRFDocument varchar(50) 
DECLARE @TransferDocument_id bigint
IF SUBSTRING(@stepInput,1,3) ='TRF'
	SELECT @TRFDocument = @stepInput
ELSE
	SELECT @TRFDocument = 'TRF.' + @stepInput
IF EXISTS(SELECT ID FROM Document WHERE Number = @Document and [Type] = 'ORDER' and [Status] in ('ENTERED','RELEASED')) 
AND NOT EXISTS(SELECT ID FROM Document WHERE Number = @TRFDocument and [Type] = 'TRANSFER')
BEGIN
		
		EXEC dbo.Utility_CopyDocument @Document, @TRFDocument, 'RELEASED','TRANSFER'
		SELECt @TransferDocument_id = ID FROM Document WHERE Number = @TRFDocument
		UPDATE DocumentDetail SET ToLocation = FromLocation WHERE Document_id = @TransferDocument_id  
		SELECT @stepInput = @TRFDocument
		UPDATE Document SET Status = 'RELEASED' WHERE Number = @Document
END
IF EXISTS(SELECT ID FROM Document WHERE Number = @TRFDocument and [Type] = 'TRANSFER' and Status IN ('RELEASED'))
BEGIN
	EXEC dbo.FIFOPickingRecommendation @TRFDocument
	SELECT @valid = 1
	SELECT @message = 'Pick Instructions updated on Transfer Document:' + @TRFDocument
	SELECT @stepInput = @TRFDocument
END
ELSE
BEGIN
	SELECT @message = 'No Transfer Document to Stage or Status not RELEASED'
	SELECT @valid = 0
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
