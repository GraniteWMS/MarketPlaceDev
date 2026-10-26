CREATE PROCEDURE [dbo].[PRescript_PrintMasterItemLabels_MasterItem] (
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
BEGIN TRY
	IF @stepInput IN (SELECT Code FROM MasterItemAlias_View)
	BEGIN
		SELECT TOP 1 @stepInput = MI.Code FROM MasterItemAlias_View MIAV INNER JOIN MasterItem MI ON MIAV.MasterItem_id = MI.ID 
		WHERE MIAV.Code = @stepInput
	END
	IF NOT EXISTS(SELECT 1 FROM MasterITem WHERE Code = @stepInput)		RAISERROR('The Item Code %s does not exist nor is it an Alias',16,1,@stepInput)	SELECT @valid = 1
	SELECT @message = @stepInput
END TRYBEGIN CATCH	SELECT @Valid = 0, @message = ERROR_MESSAGE()END CATCH	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
