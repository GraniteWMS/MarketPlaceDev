CREATE PROCEDURE [dbo].[Prescript_TakeonItemSearchV2_SerialNumber] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE
	  @valid							bit 
	, @message							varchar(MAX) 
	, @stepInput						varchar(MAX) 
	, @user								varchar(50) 
	, @masterItem						varchar(100) 
	, @masterItemEnforceSerialNumber	bit
	, @batch							varchar(100)
	, @expiryDate 						varchar(100)
	
	
	
	, @serialNumber						varchar(100) 
	, @masterItemID						bigint 
SELECT @valid					= 1 
SELECT @stepInput				= Value FROM @input WHERE Name = 'StepInput'		
SELECT @user					= Value FROM @input WHERE Name = 'User'				
SELECT @masterItem				= Value FROM @input WHERE Name = 'MasterItem'
SELECT @batch					= Value FROM @input WHERE Name = 'Batch'
SELECT @expiryDate				= Value FROM @input WHERE Name = 'ExpiryDate'
BEGIN TRY 
	SELECT @serialNumber = LTRIM(RTRIM(UPPER(@stepInput))) 
	SELECT @masterItemEnforceSerialNumber = EnforceSerialNumber FROM MasterItem WHERE Code = @masterItem 
	IF @masterItemEnforceSerialNumber = 1  
	BEGIN 
		IF ISNULL(@serialNumber,'') = '' 
			RAISERROR('SerialNumber is required for MasterItem %s ', 16, 1, @masterItem) 
		SELECT @masterItemID = ID FROM MasterItem WHERE Code = @masterItem 
		IF EXISTS (SELECT TOp 1 SerialNumber 
				   FROM TrackingEntity 
				   WHERE InStock = 1 
				   AND Qty > 0 
				   AND MasterItem_id = @masterItemID 
				   AND SerialNumber = @serialNumber
				  ) 
			RAISERROR('SerialNumber %s already exists for MasterItem %s ', 16, 1, @serialNumber, @masterItem) 
		INSERT INTO @Output 
		SELECT 'Qty', 1 
		INSERT INTO @Output 
		SELECT 'NoEntities', 1 
	END 
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	SELECT @stepInput = @serialNumber 
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
