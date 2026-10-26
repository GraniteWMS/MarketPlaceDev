CREATE PROCEDURE [dbo].[PrescriptQTYVALIDATIONQty] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit=1
DECLARE @message varchar(MAX)=''
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
SELECT @stepInput = UPPER(@stepInput)
DECLARE  @ResponseValid bit
		,@ResponseMessage varchar(max)
		,@ResponseValue varchar(50)  
EXEC UtilityValidationQty
	 @stepinput					
	,'int'						
	,NULL						
	,1							
	,1							
	,1							
	,1							
	,1							
	,1							
	,@ResponseValid OUTPUT		
	,@ResponseMessage OUTPUT	
	,@ResponseValue OUTPUT		
IF @ResponseValid = 0
BEGIN
	SELECT @valid = 0
	SELECT @message = @ResponseMessage
END
ELSE
BEGIN
	SELECT @stepinput = @ResponseValue
	SELECT @valid = 1
	SELECT @message = ''
END
	
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
