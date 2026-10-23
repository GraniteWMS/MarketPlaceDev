CREATE PROCEDURE [dbo].[Prescript_TakeonItemSearchV2_Batch] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE
	  @valid						bit 
	, @message						varchar(MAX) 
	, @stepInput					varchar(MAX) 
	, @user							varchar(50) 
	, @masterItem					varchar(100) 
	, @masterItemEnforceBatch		bit
	
	
	
	, @batch						varchar(100)
SELECT @valid					= 1 
SELECT @stepInput				= Value FROM @input WHERE Name = 'StepInput'		
SELECT @user					= Value FROM @input WHERE Name = 'User'				
SELECT @masterItem				= Value FROM @input WHERE Name = 'MasterItem'
BEGIN TRY 
	SELECT @batch = LTRIM(RTRIM(UPPER(@stepInput))) 
	SELECT @masterItemEnforceBatch = EnforceBatchNumber FROM MasterItem WHERE Code = @masterItem 
	IF @masterItemEnforceBatch = 1 
	BEGIN 
		IF ISNULL(@batch,'') = '' 
			RAISERROR('Batch is required for MasterItem %s ', 16, 1, @masterItem) 
	END
	
	
	
	
	
	select @stepInput = @batch
END TRY 
BEGIN CATCH 
	SET @valid = 0
	SET @message = 'Error: ' + ERROR_MESSAGE() 
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output	
