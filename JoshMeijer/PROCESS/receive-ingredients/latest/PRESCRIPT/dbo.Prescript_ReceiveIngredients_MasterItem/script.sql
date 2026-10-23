CREATE PROCEDURE [dbo].[Prescript_ReceiveIngredients_MasterItem] (
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
DECLARE @Supplier varchar(200)
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
SELECT @Supplier = CATEGORY FROM [dbo].[MasterItem]
WHERE Code = @stepInput
INSERT INTO @Output
SELECT 'OptionalFieldValue1',@Supplier
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
