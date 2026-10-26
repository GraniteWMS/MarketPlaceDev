CREATE PROCEDURE [dbo].[Prescript_TakeonItemSearch_MasterItemSearch] (
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
	, @itemSearchCheck				varchar(MAX) 
	, @itemSearchMaxRows			int 
	, @itemSearchMaxRowsStr			varchar(100)	
SELECT @valid					= 1 
SELECT @stepInput				= Value FROM @input WHERE Name = 'StepInput'			
SELECT @user					= Value FROM @input WHERE Name = 'User'					
SELECT @itemSearchMaxRows		= 50 
SELECT @itemSearchMaxRowsStr	= CAST(@itemSearchMaxRows as varchar)
BEGIN TRY 
	SELECT @itemSearchCheck = LTRIM(RTRIM(@stepInput)) 
	IF ISNULL(@itemSearchCheck,'') = '' 
		RAISERROR('Search criteria cannot be empty.  Use values seperated by spaces. ', 16, 1) 
	IF (SELECT COUNT(Code) RecordCount FROM FN_MasterItem_Search(@itemSearchCheck)) > @itemSearchMaxRows
		RAISERROR('Search returned more than %s records, refine your search please. ', 16, 1, @itemSearchMaxRowsStr) 
	IF EXISTS (SELECT Code FROM MasterItem WHERE Code = @itemSearchCheck) 
	BEGIN
		INSERT INTO @Output 
		SELECT 'MasterItem', @itemSearchCheck
	END
	SELECT @stepInput = @itemSearchCheck
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
