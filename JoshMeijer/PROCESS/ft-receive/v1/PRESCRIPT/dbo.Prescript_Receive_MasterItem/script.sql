CREATE PROCEDURE [dbo].[Prescript_Receive_MasterItem] (
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
	, @document						varchar(50) 
	, @documentID					bigint 
	, @location						varchar(50)
	, @labelType					varchar(50)
	, @eanBarcode					varchar(50) 
	, @masterItem					varchar(50) 
	, @masterItemID					bigint 
	, @trackingEntity				varchar(50) 
SELECT @valid			= 1 
SELECT @stepInput		= Value FROM @input WHERE Name = 'StepInput'			
SELECT @user			= Value FROM @input WHERE Name = 'User'					
SELECT @location		= Value FROM @input WHERE Name = 'Location'				
SELECT @document		= Value FROM @input WHERE Name = 'Document'				
SELECT @labelType		= Value FROM @input WHERE Name = 'LabelType'			
SELECT @eanBarcode		= Value FROM @input WHERE Name = 'EANBarcode'			
BEGIN TRY 
	IF ISNULL(@location,'') = '' 
		SELECT @location = 'REC' 
	SELECT @masterItem = UPPER(@stepInput) 
	SELECT @documentID = ID FROM Document WHERE Number = @document 
	SELECT @masterItemID = ID FROM MasterItem WHERE Code = @masterItem OR FormattedCode = @masterItem 
	IF ISNULL(@masterItemID,0) = 0 
		RAISERROR('Item Code %s is not valid ', 16, 1, @masterItem)
	IF NOT EXISTS (
					SELECT TOP 1 DD.ID, DD.Item_id, MI.Code Code, MI.Description, MI.Type  
					FROM DocumentDetail DD  
					INNER JOIN MasterItem MI ON MI.ID = DD.Item_id 
					
					WHERE DD.Document_id = @documentID 
					AND ISNULL(MI.[Type],'') = @labelType  
					AND MI.Code = @masterItem  
				  ) 
		RAISERROR('Item Code %s does not belong to document %s open lines ', 16, 1, @masterItem, @document)
	EXEC [dbo].[Utility_GetTopTrackingEntity] 
		 @MasterItemID = @masterItemID
		,@LocationBarcode = @Location
		,@TrackingEntityBarcode = @trackingEntity OUTPUT;
    INSERT INTO @Output
    SELECT 'UseBarcode', ISNULL(@TrackingEntity,'')  
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
