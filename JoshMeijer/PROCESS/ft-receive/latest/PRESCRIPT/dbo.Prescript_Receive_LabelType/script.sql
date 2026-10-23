CREATE PROCEDURE [dbo].[Prescript_Receive_LabelType] (
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
	, @labelType					varchar(50)
	, @labelTypeList				varchar(max) 
SELECT @valid			= 1 
SELECT @stepInput		= Value FROM @input WHERE Name = 'StepInput'			
SELECT @user			= Value FROM @input WHERE Name = 'User'					
SELECT @document		= Value FROM @input WHERE Name = 'Document'				
SELECT @labelType = UPPER(@stepInput) 
BEGIN TRY 
	
	SELECT @labelTypeList = Value FROM SystemStaticData WHERE [Group] = 'LabelType' AND [Key] = 'LabelTypeEAN' 
	IF ISNULL(@labelTypeList,'') = '' 
		RAISERROR('Label Type list has not been configured in SystemStaticData, contact Granite support ', 16, 1) 
	SELECT @documentID = (SELECT ID FROM Document WHERE Number = @document) 
	IF NOT EXISTS (
					SELECT TOP 1 DD.Item_id, MI.Code Code, MI.Description, MI.Type, MIAV.Code Barcode, MIAV.UOM, MIAV.Conversion 
					FROM DocumentDetail DD  
					INNER JOIN MasterItem MI ON MI.ID = DD.Item_id 
					LEFT OUTER JOIN MasterItemAlias_View MIAV ON MIAV.MasterItem_id = MI.ID 
					WHERE DD.Document_id = @documentID 
					AND ISNULL(MI.[Type],'') = @labelType  
				  ) 
		RAISERROR('Label Type %s does not belong to document %s open lines', 16, 1, @labelType, @document) 
	IF @labelTypeList NOT LIKE CONCAT('%',@labelType,'%')  
	BEGIN 
		INSERT INTO @Output
		SELECT 'EANBarcode', 'XXXXXX'  
	END
	ELSE
	BEGIN
		INSERT INTO @Output
		SELECT 'EANBarcode', '' 
	END
	INSERT INTO @Output
	SELECT 'MasterItem', '' 
	INSERT INTO @Output
	SELECT 'Qty', '' 
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
