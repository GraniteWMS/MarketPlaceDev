CREATE PROCEDURE [dbo].[PrescriptPickingDocument] (
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
DECLARE @DocStatus varchar(30)
DECLARE @DocType varchar(30)
BEGIN TRY
IF NOT EXISTS(SELECT 1 FROM Document WHERE Number = @stepInput AND [Type] IN ('ORDER', 'PICKSLIP'))
	RAISERROR('The Document %s does not Exist as a Picking Document',16,1,@stepInput)
SELECT @DocStatus = [Status], @DocType = [Type] FROM Document WHERE Number = @stepInput
IF @DocStatus NOT IN ('ENTERED', 'RELEASED')
	RAISERROR('The Document %s is not in STatus ENTERED or RELEASED',16,1,@stepInput)
IF @DocStatus = 'ENTERED' 	UPDATE Document SET [Status] = 'RELEASED' WHERE Number = @stepInputEXEC dbo.FIFOPickingRecommendation @stepInput
END Try
BEGIN CATCH
	SELECT @Valid = 0, 
	@message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
