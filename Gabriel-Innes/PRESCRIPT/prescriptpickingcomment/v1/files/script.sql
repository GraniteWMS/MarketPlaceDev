CREATE PROCEDURE [dbo].[PrescriptPickingComment] (
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
DECLARE @CarryingEntityId bigint
SELECT @CarryingEntityId = ID FROM CarryingEntity where Barcode = @stepInput
IF(ISNULL(@CarryingEntityId,0) = 0)
BEGIN
	SELECT @valid = 0, @message = @stepInput + ' is not a valid carrying entity.', @stepInput = ''
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
