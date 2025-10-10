CREATE PROCEDURE [dbo].[PrescriptUnpackBoxBarcode] (
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
DECLARE @Barcode varchar (30) = @stepInput
DECLARE @CarryingEntityId bigint
	

IF NOT EXISTS(SELECT ID FROM CarryingEntity WHERE Barcode = @Barcode)
BEGIN
	SELECT @valid = 0                  
	SELECT @message = 'Carrying Entity ' + @Barcode + ' does not exist.'  
END
ELSE 
BEGIN 
    SELECT @CarryingEntityId = ID FROM CarryingEntity WHERE Barcode = @Barcode

	IF EXISTS(SELECT * FROM [Transaction] WHERE Type = 'PACK' AND IntegrationStatus = 0 AND ContainableEntity_id = @CarryingEntityId AND ReversalTransaction_id IN (NULL, 0))
	BEGIN 
		SELECT @valid = 1
		SELECT @message = ''

	END
	ELSE
	BEGIN
		SELECT @valid = 0
		SELECT @message = 'Nothing to unpack on Barcode: ' + @Barcode
	END

END



INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput


SELECT * FROM @Output
