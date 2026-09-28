CREATE PROCEDURE [dbo].[Prescript_3PL_ReleaseLoadoutConfirmation] (
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
DECLARE @Document varchar(50) = (SELECT Value FROM @input WHERE Name = 'Document' )
DECLARE @TRFDocument varchar(50) 
DECLARE @TransferDocument_id bigint
IF SUBSTRING(@stepInput,1,3) ='TRF'
	SELECT @TRFDocument = @Document
ELSE
	SELECT @TRFDocument = 'TRF.' + @Document
IF EXISTS(SELECT ID FROM Document WHERE Number = @Document and [Type] = 'ORDER' and [Status] in ('ENTERED','RELEASED')) 
AND NOT EXISTS(SELECT ID FROM Document WHERE Number = @TRFDocument and [Type] = 'TRANSFER')
BEGIN
		
		EXEC dbo.Utility_CopyDocument @Document, @TRFDocument, 'RELEASED','TRANSFER'
		SELECT @TransferDocument_id = ID FROM Document WHERE Number = @TRFDocument
		UPDATE DocumentDetail SET ToLocation = FromLocation WHERE Document_id = @TransferDocument_id  
END
IF EXISTS(SELECT ID FROM Document WHERE Number = @TRFDocument and [Type] = 'TRANSFER' and Status IN ('ENTERED', 'RELEASED'))
BEGIN
	EXEC dbo.FIFOPickingRecommendation @TRFDocument
	SELECT @valid = 1
	SELECT @message = 'Pick Instructions updated on Transfer Document:' + @TRFDocument
	
END
ELSE
BEGIN
	SELECT @message = 'No Transfer Document to Release'
	SELECT @valid = 0
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
