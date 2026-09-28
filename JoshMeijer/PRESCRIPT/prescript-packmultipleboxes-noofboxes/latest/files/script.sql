CREATE PROCEDURE [dbo].[Prescript_PackMultipleBoxes_NoOfBoxes] (
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
DECLARE @stepInput varchar(MAX) = (SELECT Value FROM @input WHERE Name = 'StepInput') 
SET @valid = 1
SET @message = @stepInput
IF @stepInput > 100
BEGIN
	SET @valid = 0
	SET @message = 'Maximum of 100 boxes allowed at a time'
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
