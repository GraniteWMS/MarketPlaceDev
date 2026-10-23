CREATE PROCEDURE [dbo].[WebTemplate_SP_MasterItemSearch] 
    @masterItemSearch NVARCHAR(MAX)
AS
BEGIN
	SELECT * 
	FROM FN_MasterItem_Search(@masterItemSearch)  
END
