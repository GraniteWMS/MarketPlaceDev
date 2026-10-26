CREATE PROCEDURE [dbo].[Prescript_Receiving_Document] (
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
BEGIN TRY
	IF EXISTS(SELECT 1 FROM Document WHERE Number = @stepInput and [Type] ='RECEIVING' and [Status] = 'ENTERED')
		UPDATE Document SET [Status] = 'RELEASED' WHERE Number = @stepInput
		
	SELECT @valid = 1
	SELECT @message = @stepInput
END TRY
BEGIN CATCH
	SELECT @valid = 0
	,@message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
