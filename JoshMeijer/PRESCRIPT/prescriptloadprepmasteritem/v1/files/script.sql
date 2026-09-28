CREATE PROCEDURE [dbo].[PrescriptLoadPrepMasterItem] (
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
DECLARE @Document varchar(50)
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput'	
SELECT @Document = Value FROM @input WHERE Name = 'Document'	
IF EXISTS(SELECT ItemCode FROM WebTemplate_LoadPrepItems WHERE ItemCode = @stepInput AND Document = @Document)
BEGIN
	SELECT @valid = 1
	SELECT @message = ''
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = CONCAT(@stepInput,' is not a valid item for this Sales Order.')
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
