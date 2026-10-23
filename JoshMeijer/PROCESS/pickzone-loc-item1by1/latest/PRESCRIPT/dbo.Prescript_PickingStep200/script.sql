CREATE PROCEDURE [dbo].[Prescript_PickingStep200] (
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
DECLARE @LPReset bit = 0		
	EXEC dbo.FIFOPickingRecommendation @Document = @stepInput, @LPReset = @LPReset
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
