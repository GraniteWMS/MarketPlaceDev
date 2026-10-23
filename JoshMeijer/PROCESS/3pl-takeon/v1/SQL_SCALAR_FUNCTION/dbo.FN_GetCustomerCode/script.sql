CREATE FUNCTION [dbo].[FN_GetCustomerCode] (@Key varchar(50), @KeyType varchar(20))
RETURNS nvarchar(100) 
AS 
BEGIN 
	
	
	
	DECLARE @RetValue varchar(100)
	DECLARE @OptFieldID bigint
	DECLARE @MasterItem_id bigint
	DECLARE @TrackingEntity_id bigint
	DECLARE @Location_id bigint
	DECLARE @CarryingEntity_id bigint
	SELECT @OptFieldID = ID FROM OptionalFields WHERE [Name] = '3PLCUSTOMER' AND AppliesTo = 'MASTERITEM'
	
	IF @KeyType = 'TRACKINGENTITY'
	BEGIN
		SELECT @TrackingEntity_id = ID FROM TrackingEntity WHERE Barcode = @Key
		SELECT @MasterItem_id = MasterItem_id FROM TrackingEntity WHERE ID = @TrackingEntity_id
		
		SELECT @RetValue = ISNULL([Value], 'INVALID') FROM OptionalFieldValues_MasterItem WHERE OptionalField_id = @OptFieldID AND BelongsTo_id = @MasterItem_id
	END
	ELSE IF @KeyType = 'CARRYINGENTITY'
	BEGIN
		SELECT @CarryingEntity_id = ID FROM CarryingEntity WHERE Barcode = @Key
		SELECT @TrackingEntity_id = (SELECT TOP 1 ID FROM TrackingEntity WHERE InStock = 1 AND Qty > 0 AND BelongsToEntity_id = @CarryingEntity_id)
		SELECT @MasterItem_id = MasterItem_id FROM TrackingEntity WHERE ID = @TrackingEntity_id
		
		SELECT @RetValue = ISNULL([Value], 'INVALID') FROM OptionalFieldValues_MasterItem WHERE OptionalField_id = @OptFieldID AND BelongsTo_id = @MasterItem_id
	END
	ELSE IF @KeyType = 'LOCATION'
	BEGIN
		SELECT @Location_id = ID FROM [Location] WHERE Barcode = @Key OR [Name] = @Key
		SELECT @TrackingEntity_id = (SELECT TOP 1 ID FROM TrackingEntity WHERE InStock = 1 AND Qty > 0 AND Location_id = @Location_id)
		SELECT @MasterItem_id = MasterItem_id FROM TrackingEntity WHERE ID = @TrackingEntity_id
		
		SELECT @RetValue = ISNULL([Value], 'INVALID') FROM OptionalFieldValues_MasterItem WHERE OptionalField_id = @OptFieldID AND BelongsTo_id = @MasterItem_id
	END
	ELSE IF @KeyType = 'MASTERITEM'
	BEGIN
		IF EXISTS(SELECT ID FROM MasterItem WHERE Code = @Key)
		BEGIN
			SELECT @MasterItem_id = ID FROM MasterItem WHERE Code = @Key
		END
		ELSE IF EXISTS(SELECT ID FROM MasterItemAlias WHERE Code = @Key)
		BEGIN
			SELECT @MasterItem_id = MasterItem_id FROM MasterItemAlias WHERE Code = @Key
		END
		SELECT @RetValue = ISNULL([Value], 'INVALID') FROM OptionalFieldValues_MasterItem WHERE OptionalField_id = @OptFieldID AND BelongsTo_id = @MasterItem_id
	END
	ELSE
	BEGIN
		SELECT @RetValue = 'INVALID'
	END
    RETURN @RetValue 
END
