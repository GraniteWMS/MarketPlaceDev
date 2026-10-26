
CREATE PROCEDURE [dbo].[PrescriptPackQty] (
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
DECLARE @user varchar(30) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @stepInput varchar(MAX) = (SELECT Value FROM @input WHERE Name = 'StepInput') 

DECLARE @sql varchar(max)
DECLARE @OrderBy varchar(max)
DECLARE @html varchar(max) = ''
DECLARE @CarryingEntity varchar(50) = (SELECT Value FROM @input WHERE Name = 'CarryingEntity')


IF LEN(@stepInput) > 6
BEGIN

	SELECT @Valid = 0
	SELECT @Message = 'Order Quantity cannot be more than 1 000 000'
END


	SELECT @html = '<br>'


INSERT INTO @Output
SELECT 'Instruction', @html

INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput

SELECT * FROM @Output

