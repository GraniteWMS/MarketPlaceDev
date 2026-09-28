CREATE PROCEDURE [dbo].[Common_SP_GetMasterItemLinkedToAlias]
(
@Alias varchar(50),
@MasterItemCode varchar(50) OUTPUT,
@MasterItemID bigint OUTPUT
)
AS
BEGIN
	DECLARE @AliasLength int = LEN(@Alias);
	IF @AliasLength <= 1
	BEGIN
		RETURN;
	END
	SELECT 
	@MasterItemID = ID, 
	@MasterItemCode = Code
	FROM dbo.MasterItem WHERE Code = @Alias;
	IF ISNULL(@MasterItemID, 0) <> 0
	BEGIN
		RETURN;
	END
	SELECT TOP 1 
	@MasterItemID = MasterItem_id
	FROM dbo.MasterItemAlias_View WHERE 
	Code = @Alias
	IF ISNULL(@MasterItemID, 0) = 0
	BEGIN
		SELECT TOP 1 
		@MasterItemID = MasterItem_id
		FROM dbo.MasterItemAlias_View WHERE 
		Code = SUBSTRING(@Alias, 1, @AliasLength - 1)
		OR Code = CONCAT('0', @Alias)
		OR Code = CONCAT(@Alias, '5')
		OR Code = CONCAT(@Alias, '6')
		OR Code = CONCAT(@Alias, '7');
	END
	SELECT @MasterItemCode = Code FROM MasterItem WHERE ID = @MasterItemID;
END