CREATE PROCEDURE [dbo].[PrescriptTakeonProductionMasterItem] (
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
DECLARE @ManufactureDate varchar(8)
DECLARE @Batch varchar(30)
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
BEGIN TRY
	
	IF NOT EXISTS(SELECT 1 FROM WebTemplate_MasterItemswithBOMS WHERE Code = @stepInput)
		RAISERROR('This Finished goods code %s does not have an Active Bill of Materials',16,1,@stepInput)
	SELECT @ManufactureDate =  CONVERT(varchar(8),getdate(),112)
	INSERT INTO @Output
	SELECT 'ManufactureDate', @ManufactureDate
	SELECT @Batch = ''
	INSERT INTO @Output
	SELECT 'Batch', @Batch
END TRY
BEGIN CATCH
	SELECT @valid = 0, @message = ERROR_MESSAGE()
END CATCH	
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
