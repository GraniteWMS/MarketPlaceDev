CREATE   PROCEDURE [dbo].[Prescript_ScrapBarcode_Comment] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
	DECLARE @Comment varchar(50)
	DECLARE @Reference varchar(50)
	SELECT @Comment = Value FROM @input WHERE Name = 'Comment' 
	SELECT @Reference = Value FROM @input WHERE Name = 'Reference' 
	
IF ISNULL(@Comment,'') = '' AND @Reference = 'OTHER'
BEGIN
	SELECT @valid = 0
	SELECT @Message = 'Details cannot be left empty if choosing "OTHER"'
END
	
	
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
