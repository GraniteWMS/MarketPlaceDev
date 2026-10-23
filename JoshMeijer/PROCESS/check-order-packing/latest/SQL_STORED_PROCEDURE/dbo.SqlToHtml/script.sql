CREATE PROCEDURE [dbo].[SqlToHtml] 
	
	@SQL varchar(max),
	@OrderBy varchar(max),
	@HTML varchar(max) OUTPUT
AS
BEGIN
	
	
	SET NOCOUNT ON;

	DECLARE @columnlist varchar(max)
	DECLARE @xmlData varchar(max)
	DECLARE @SQL2 nvarchar(max) 
	DECLARE @ColumnName varchar(100)
	DECLARE @header varchar(max)

	SELECT @OrderBy = ISNULL(@OrderBy, '')

	SELECT @header =  tbl.header
	FROM
	(SELECT
	(SELECT name as th
	FROM sys.dm_exec_describe_first_result_set(@SQL, NULL, 0)
	WHERE name <> 'RowColor' AND LEFT(name, 1) <> '_'
	FOR XML PATH('')) as header) as tbl


	SELECT @columnlist = REPLACE(REPLACE(tbl.xml2, '<c>', ''), '</c>', ',')
	FROM(SELECT
		(SELECT name as c
		FROM sys.dm_exec_describe_first_result_set(@SQL, NULL, 0)
		WHERE name <> 'RowColor'
		FOR XML PATH('')) as xml2) tbl

	SELECT @columnlist = LEFT(@columnlist, LEN(@columnlist) - 1)

	SELECT @SQL2 = CONCAT('SELECT @xmlData = 
						(SELECT CASE WHEN RowColor <> '''' THEN RowColor ELSE ''x'' END as x, ', @columnlist, ', ''y'' as y 
						FROM (', @SQL, ') temptbl 
						',@OrderBy,'
						FOR XML PATH(''''),ROOT(''root''), ELEMENTS XSINIL)')
	
	EXEC sp_executesql @SQL2, N'@xmlData varchar(max) output', @xmlData output


	SELECT @xmlData = REPLACE(@xmlData, '<root xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">', '')
	SELECT @xmlData = REPLACE(@xmlData, '</root>', '')
	SELECT @xmlData = REPLACE(@xmlData, 'xsi:nil="true"', '')
	SELECT @xmlData = REPLACE(@xmlData, '<x>x</x>', '<tr>')
	SELECT @xmlData = REPLACE(@xmlData, '<x>', '<tr style="background-color:')
	SELECT @xmlData = REPLACE(@xmlData, '</x>', '">')
	SELECT @xmlData = REPLACE(@xmlData, '<y>y</y>', '</tr>')

	DECLARE c CURSOR FOR
	SELECT name
	FROM sys.dm_exec_describe_first_result_set(@SQL, NULL, 0)

	OPEN c

	FETCH NEXT FROM c INTO @columnName

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @xmlData = REPLACE(@xmlData, CONCAT('<', @columnName, '>'), '<td>')
		SELECT @xmlData = REPLACE(@xmlData, CONCAT('</', @columnName, '>'), '</td>')
		SELECT @xmlData = REPLACE(@xmlData, CONCAT('<', @columnName, ' />'), '<td></td>')
			   
		FETCH NEXT FROM c INTO @columnName
	END
 
	CLOSE c
	DEALLOCATE c


	SELECT @html = CONCAT('
	<table class="table">
		<thead>
			<tr>
			',@header,'
			</tr>
		</thead>
		<tbody>
			',@xmlData,'
		</tbody>
	</table>
	')


END
