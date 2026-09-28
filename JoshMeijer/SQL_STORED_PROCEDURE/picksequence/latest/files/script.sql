
CREATE PROCEDURE [dbo].[PickSequence]
AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @ExcludeLocations varchar(max)
	DECLARE @ExcludeLocationTypes varchar(max)
	DECLARE @ExcludeLocationCategories varchar(max)
	DECLARE @LineOrderBy varchar(max)
	DECLARE @SQL varchar(max)
    SELECT @ExcludeLocations = CASE WHEN ISNULL(ExcludeLocations,'') = '' THEN 'NoExclusions' ELSE ExcludeLocations END,
		   @ExcludeLocationTypes = CASE WHEN ISNULL(ExcludeLocationTypes,'') = '' THEN 'NoExclusions' ELSE ExcludeLocationTypes END,
		   @ExcludeLocationCategories = CASE WHEN ISNULL(ExcludeLocationCategories,'') = '' THEN 'NoExclusions' ELSE ExcludeLocationCategories END,
		   @LineOrderBy = LineOrderBy
	FROM (SELECT [Value], [Key]
		  FROM SystemStaticData
		  WHERE [Group] = 'PickingSuggestion'
		 ) TSQL
	PIVOT(MIN([Value])
		  FOR [Key] IN (ExcludeLocations,
						ExcludeLocationTypes,
						ExcludeLocationCategories,
						LineOrderBy)
		 ) AS Piv
		 
	SET @SQL = CONCAT('SELECT L.Barcode, ROW_NUMBER() OVER(ORDER BY ',@LineOrderBy,') '
					 ,'FROM [Location] L '
					 ,'WHERE L.Barcode NOT IN (''',REPLACE(@ExcludeLocations,',',''','''),''') '
					 ,'AND ISNULL(L.Type,'''') NOT IN (''',REPLACE(@ExcludeLocationTypes,',',''','''),''') '
					 ,'AND ISNULL(L.Category,'''') NOT IN (''',REPLACE(@ExcludeLocationCategories,',',''','''),''') '
					 ,'AND L.NonStock = 0')
	
	EXEC (@SQL)
END
