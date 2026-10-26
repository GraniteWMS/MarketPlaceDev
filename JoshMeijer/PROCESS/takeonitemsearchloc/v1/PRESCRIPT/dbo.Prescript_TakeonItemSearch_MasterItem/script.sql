CREATE PROCEDURE [dbo].[Prescript_TakeonItemSearch_MasterItem] (
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
	, @masterItemEnforceExpiry		bit 
	, @masterItemEnforceSerial		bit 
SELECT @valid					= 1 
SELECT @stepInput				= Value FROM @input WHERE Name = 'StepInput'			
SELECT @user					= Value FROM @input WHERE Name = 'User'					
BEGIN TRY 
	SELECT @masterItem = LTRIM(RTRIM(@stepInput)) 
	IF ISNULL(@masterItem,'') = '' 
		RAISERROR('MasterItem cannot be empty. ', 16, 1) 
	SELECT @masterItemEnforceBatch = EnforceBatchNumber 
		  ,@masterItemEnforceExpiry	= EnforceExpiryDate 
		  ,@masterItemEnforceSerial = EnforceSerialNumber 
	FROM MasterItem 
	WHERE Code = @masterItem 
	IF @masterItemEnforceBatch = 1 
		INSERT INTO @Output 
		SELECT 'GetBatch', 'YES' 
	ELSE 
		INSERT INTO @Output 
		SELECT 'GetBatch', 'NO' 
	IF @masterItemEnforceExpiry = 1 
		INSERT INTO @Output 
		SELECT 'GetExpiryDate', 'YES' 
	ELSE
		INSERT INTO @Output 
		SELECT 'GetExpiryDate', 'NO' 
	IF @masterItemEnforceSerial = 1 
		INSERT INTO @Output 
		SELECT 'GetSerialNumber', 'YES' 
	ELSE 
		INSERT INTO @Output 
		SELECT 'GetSerialNumber', 'NO' 
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
