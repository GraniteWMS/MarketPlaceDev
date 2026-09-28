CREATE FUNCTION [dbo].[FN_GetOptionalField] (@FieldName Varchar(100),@AppliesTo varchar(30), @Key varchar(50))
RETURNS nvarchar(100) 
AS 
BEGIN 
	DECLARE @RetValue varchar(100)
	DECLARE @OptFieldID BIGINT
	DECLARE @Key_id BIGINT
	SELECT @OptFieldID = ID FROM OptionalFields WHERE Name = @FieldName and AppliesTo = @AppliesTo
	IF @AppliesTo = 'MASTERITEM'
	BEGIN
		SELECT @Key_id = ID FROM MasterItem WHERE Code = @Key
		SELECT TOP 1 @RetValue = Value FROM OptionalFieldValues_MasterItem 
		WHERE OptionalField_id = @OptFieldID AND BelongsTo_id = @Key_id
	END
	IF @AppliesTo = 'TRACKINGENTITY'
	BEGIN
		SELECT @Key_id = ID FROM TrackingEntity WHERE Barcode = @Key
		SELECT TOP 1 @RetValue = Value FROM OptionalFieldValues_TrackingEntity 
		WHERE OptionalField_id = @OptFieldID AND BelongsTo_id = @Key_id
	END	
	IF @AppliesTo = 'DOCUMENT'
	BEGIN
		SELECT @Key_id = ID FROM Document WHERE Number = @Key
		SELECT TOP 1 @RetValue = Value FROM OptionalFieldValues_Document  
		WHERE OptionalField_id = @OptFieldID AND BelongsTo_id = @Key_id
	END	
	IF @AppliesTo = 'DOCUMENTDETAIL'
	BEGIN
		SELECT @Key_id = ID FROM DocumentDetail WHERE ID = @Key
		SELECT TOP 1 @RetValue = Value FROM OptionalFieldValues_DocumentDetail   
		WHERE OptionalField_id = @OptFieldID AND BelongsTo_id = @Key_id
	END	
	IF @AppliesTo = 'LOCATION'
	BEGIN
		SELECT @Key_id = ID FROM Location WHERE Barcode = @Key
		SELECT TOP 1 @RetValue = Value FROM OptionalFieldValues_Location   
		WHERE OptionalField_id = @OptFieldID AND BelongsTo_id = @Key_id
	END	
    RETURN @RetValue 
END
