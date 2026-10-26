CREATE PROCEDURE [dbo].[Prescript_Receive_EANBarcode] (
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
	, @eanBarcode					varchar(50) 
	, @eanMasterItem				varchar(50) 
	, @eanQty						decimal(19,0) 
SELECT @valid			= 1 
SELECT @stepInput		= Value FROM @input WHERE Name = 'StepInput'			
SELECT @user			= Value FROM @input WHERE Name = 'User'					
SELECT @document		= Value FROM @input WHERE Name = 'Document'				
SELECT @labelType		= Value FROM @input WHERE Name = 'LabelType'			
SELECT @eanBarcode = UPPER(@stepInput) 
BEGIN TRY 
	
	IF ISNULL(@eanBarcode,'') = ''
	BEGIN 
		SELECT @labelTypeList = Value FROM SystemStaticData WHERE [Group] = 'LabelType' AND [Key] = 'LabelTypeEAN' 
		IF @labelTypeList NOT LIKE CONCAT('%',@labelType,'%')  
		BEGIN 
			SELECT @stepInput = 'XXXXXX'  
			SELECT @eanBarcode = @stepInput 
		END
	END
	
	
	IF ISNULL(@eanBarcode,'') <> 'XXXXXX' 
	BEGIN 
		SELECT @documentID = (SELECT ID FROM Document WHERE Number = @document) 
		IF NOT EXISTS (
						SELECT TOP 1 DD.Item_id, MI.Code Code, MI.Description, MI.Type, MIAV.Code Barcode, MIAV.UOM, ISNULL(MIAV.Conversion, 1) Conversion
						FROM DocumentDetail DD  
						INNER JOIN MasterItem MI ON MI.ID = DD.Item_id 
						LEFT OUTER JOIN MasterItemAlias_View MIAV ON MIAV.MasterItem_id = MI.ID 
						WHERE DD.Document_id = @documentID 
						AND ISNULL(MI.[Type],'') = @labelType  
						AND ISNULL(MIAV.Code,'') = @eanBarcode 
						ORDER BY DD.ID 
					  ) 
			RAISERROR('Barcode %s does not belong to document %s open lines', 16, 1, @eanBarcode, @document)
		SELECT DISTINCT @eanMasterItem = MI.Code
			  ,@eanQty = MIAV.Conversion 
		FROM DocumentDetail DD  
		INNER JOIN MasterItem MI ON MI.ID = DD.Item_id 
		LEFT OUTER JOIN MasterItemAlias_View MIAV ON MIAV.MasterItem_id = MI.ID 
		WHERE DD.Document_id = @documentID 
		AND ISNULL(MI.[Type],'') = @labelType  
		AND MIAV.Code = @eanBarcode  
		INSERT INTO @Output 
		SELECT 'MasterItem', @eanMasterItem 
		INSERT INTO @Output 
		SELECT 'Qty', @eanQty 
	END
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
