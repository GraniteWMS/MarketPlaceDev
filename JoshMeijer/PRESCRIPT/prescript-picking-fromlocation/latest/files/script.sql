CREATE PROCEDURE [dbo].[Prescript_Picking_FromLocation] (
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
DECLARE @LocationIdentifier varchar (50)
DECLARE @Exists bit
DECLARE @LocationBarcode varchar (50)
SELECT @LocationIdentifier = UPPER(@stepInput)
EXEC dbo.ValidateLocation @LocationIdentifier,
						  @Exists OUTPUT, 
						  @LocationBarcode OUTPUT
IF @Exists = 1
	SELECT	@valid = 1 ,@stepInput = @LocationBarcode
ELSE
	SELECT @valid = 0 ,@message = CONCAT('Location ', @LocationIdentifier, ' does not exist or is inactive')
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
