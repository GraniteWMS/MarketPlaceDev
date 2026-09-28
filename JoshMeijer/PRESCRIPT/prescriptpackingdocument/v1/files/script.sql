CREATE PROCEDURE [dbo].[PrescriptPackingDocument] (
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
DECLARE @Document varchar(50) = @stepInput
DECLARE @DocumentID bigint
DECLARE @Location varchar(30)
DECLARE @ERPLocation varchar(30)
IF EXISTS (SELECT 1 FROM Document WHERE Number = CONCAT('D', @Document))
BEGIN
	SELECT @stepInput = CONCAT('D', @Document)
	SELECT @valid = 1
	SELECT @message = ''
END
ELSE
IF EXISTS (SELECT 1 FROM Document WHERE Number = @Document AND [Type] = 'PICKSLIP')
BEGIN
	SELECT @valid = 1
	SELECT @message = ''
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = CONCAT(@Document, ' is not a valid SALES ORDER document')
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
