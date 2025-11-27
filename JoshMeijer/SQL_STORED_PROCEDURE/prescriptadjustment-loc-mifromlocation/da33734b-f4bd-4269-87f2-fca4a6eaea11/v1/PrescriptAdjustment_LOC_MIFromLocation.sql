CREATE PROCEDURE [dbo].[PrescriptAdjustment_LOC_MIFromLocation] (
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
BEGIN

	SELECT @valid = 1
	SELECT @stepInput = @LocationBarcode

END
ELSE
BEGIN

	SELECT @valid = 0
	SELECT @message = CONCAT('Location ', @LocationIdentifier, ' does not exist or is inactive')

END

	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput

	SELECT * FROM @Output
