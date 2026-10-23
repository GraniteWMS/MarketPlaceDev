CREATE PROCEDURE [dbo].[PrescriptUnconsumeDocument] (
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
	SELECT @Document = @stepInput

IF EXISTS (SELECT * FROM Document WHERE Number = @Document AND Type = 'WORKORDER')
	BEGIN
		SELECT @valid = 1
	END
ELSE
	BEGIN
		SELECT @valid = 0, @message = CONCAT(@Document, ' not a valid Work Order')
	END




	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
