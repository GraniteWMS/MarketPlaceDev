CREATE PROCEDURE [dbo].[Prescript_TakeonItemSearch_Location] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE
	  @valid					bit 
	, @message					varchar(MAX) 
	, @stepInput				varchar(MAX) 
	, @user						varchar(50) 
	, @location					varchar(50) 
	, @locationID				bigint 
	, @locationIsActive			bit 
	, @locationNonStock			bit 
SELECT @valid			= 1 
SELECT @stepInput		= Value FROM @input WHERE Name = 'StepInput'			
SELECT @user			= Value FROM @input WHERE Name = 'User'					
BEGIN TRY 
	SELECT @location = UPPER(@stepInput) 
	IF ISNULL(@location,'') = '' 
		RAISERROR('Location cannot be empty ', 16, 1, @location) 
	SELECT @locationID = ID 
		  ,@locationIsActive = isActive 
		  ,@locationNonStock = NonStock 
	FROM [Location] 
	WHERE Barcode = @location 
	IF ISNULL(@locationID,0) = 0 
		RAISERROR('Location %s is not a valid location barcode ', 16, 1, @location) 
	IF ISNULL(@locationIsActive,0) = 0 
		RAISERROR('Location %s is not Active ', 16, 1, @location)
	IF ISNULL(@locationNonStock,0) = 1 
		RAISERROR('Location %s is Non Stock ', 16, 1, @location)
	SELECT @stepInput = @location 
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
