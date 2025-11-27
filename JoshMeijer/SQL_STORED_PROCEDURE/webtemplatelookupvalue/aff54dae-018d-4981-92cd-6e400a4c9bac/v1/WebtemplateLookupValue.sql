CREATE PROCEDURE [dbo].[WebtemplateLookupValue]
	@MasterItem varchar(100) 
AS
BEGIN 
	DECLARE @MIID BIGINT

	IF EXISTS(SELECT CODE FROM MasterItemAlias_View WHERE CODE = @MasterItem)
	BEGIN
			SELECT @MIID = MasterItem_id  FROM MasterItemAlias_View WHERE Code = @MasterItem
	END
	ELSE
	BEGIN
			SELECT @MIID = ID FROM MasterItem WHERE Code = @MasterItem
	END


	DECLARE @IMAGEURL VARCHAR(250)
			SELECT @IMAGEURL = VALUE FROM	OptionalFieldValues_MasterItem
											INNER JOIN OptionalFields ON OptionalFieldValues_MasterItem.OptionalField_id = OptionalFields.ID
			WHERE BelongsTo_id = @MIID AND OptionalFields.Name = 'ImageURL'

	SELECT @IMAGEURL
END



