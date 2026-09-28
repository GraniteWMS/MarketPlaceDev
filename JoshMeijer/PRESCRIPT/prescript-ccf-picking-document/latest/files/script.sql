CREATE PROCEDURE [dbo].[Prescript_CCF_PICKING_Document] (
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
DECLARE @Status varchar(30)
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
BEGIN TRY
	IF NOT EXISTS(SELECT 1 FROM Document WHERE Number = @stepInput and [Type] = 'ORDER')
		RAISERROR('The entered Document %s does not not exist as a sales order or may not be integrated yet',16,1,@stepInput)
	SELECT @Status = [Status] FROM Integration_Accpac_SalesOrderHeader WHERE Number = @stepInput 
	
	IF @Status = 'COMPLETE'
		RAISERROR('The entered Document %s is COMPLETE -you cannot pick against it.',16,1,@stepInput)
	IF @Status = 'CANCELLED'
		RAISERROR('The entered Document %s is CANCELLED -you cannot pick against it.',16,1,@stepInput)
	IF @Status = 'ONHOLD'
		RAISERROR('The entered Document %s is ONHOLD -you cannot pick against it.',16,1,@stepInput)
	EXEC dbo.FIFOPickingRecommendation @stepInput
END TRY
BEGIN CATCH
	SELECT @Valid = 0, @message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
