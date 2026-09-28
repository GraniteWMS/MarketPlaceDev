
CREATE PROCEDURE [dbo].[Prescript_CCF_PACKPALLET_MasterItem] (
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
DECLARE @site varchar(10) = 'CCF'
DECLARE @julianDateCode  varchar(5) = dbo.GenerateJulianDateCode(getdate())
DECLARE @Batch varchar(50)
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @MasterItemCode varchar(50) = @StepInput
BEGIN TRY
	IF NOT EXISTS (SELECT 1 FROM MasterItem WHERE Code = @MasterItemCode or FormattedCode = @MasterItemCode 
	and [Type] = 'FG') 
		RAISERROR('The Item Code %s is not a valid Finished Goods item for CCF',16,1, @MasterItemCode)
	
	SELECT @Batch = CONCAT(@julianDateCode,'-',@site)
	INSERT INTO @Output
	SELECT 'Batch', @Batch
	SELECT @valid = 1
	SELECT @message = ''
END TRY
BEGIN CATCH
		SELECT @valid = 0
		SELECT @message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
