CREATE PROCEDURE [dbo].[Prescript_Receiving_MasterItem] (
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
IF @stepInput IN (SELECT Code FROM MasterItemAlias_View)
BEGIN
	SELECT TOP 1 @stepInput = MI.Code FROM MasterItemAlias_View MIAV INNER JOIN MasterItem MI ON MIAV.MasterItem_id = MI.ID 
	WHERE MIAV.Code = @stepInput
END
SELECT @valid = 1
SELECT @message = @stepInput
INSERT INTO @Output
SELECT 'UseBarcode', @stepInput
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
