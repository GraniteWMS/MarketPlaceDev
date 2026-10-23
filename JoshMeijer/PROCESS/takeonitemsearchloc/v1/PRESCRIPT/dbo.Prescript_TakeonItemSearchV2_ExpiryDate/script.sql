CREATE PROCEDURE [dbo].[Prescript_TakeonItemSearchV2_ExpiryDate] (
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
	, @masterItemEnforceExpiryDate	bit
	, @batch						varchar(100)
	
	
	
	, @expiryDate 					varchar(100)
SELECT @valid					= 1 
SELECT @stepInput				= Value FROM @input WHERE Name = 'StepInput'		
SELECT @user					= Value FROM @input WHERE Name = 'User'				
SELECT @masterItem				= Value FROM @input WHERE Name = 'MasterItem'
SELECT @batch					= Value FROM @input WHERE Name = 'Batch'
BEGIN TRY 
	SELECT @expiryDate = LTRIM(RTRIM(@stepInput)) 
	SELECT @masterItemEnforceExpiryDate = EnforceExpiryDate FROM MasterItem WHERE Code = @masterItem 
	IF @masterItemEnforceExpiryDate = 1 
	BEGIN 
		IF ISNULL(@expiryDate,'') = '' 
			RAISERROR('ExpiryDate is required for MasterItem %s ', 16, 1, @masterItem) 
		IF LEN(@expiryDate) <> 8 
			RAISERROR('ExpiryDate %s invalid, must be 8 characters, format should be YYYYMMDD ', 16, 1, @expiryDate)
		IF TRY_CONVERT(DATE, @expiryDate) IS NULL 
			RAISERROR('ExpiryDate %s is not a valid date, format should be YYYYMMDD ', 16, 1, @expiryDate) 
	END
	
	
	
	
	
	
	
	
	
	SELECT @stepInput = @expiryDate 
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
