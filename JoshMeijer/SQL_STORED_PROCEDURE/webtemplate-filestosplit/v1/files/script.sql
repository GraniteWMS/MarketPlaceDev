CREATE PROCEDURE [dbo].[WebTemplate_FilesToSplit]
AS
BEGIN
DECLARE @path nvarchar(4000) = N'C:\Users\Administrator\Dropbox\ExcelTransfers';
CREATE TABLE #dir (
  subdirectory nvarchar(4000),
  depth        int,
  [file]       bit
);
INSERT #dir
EXEC master.sys.xp_dirtree @path, 1, 1;  
SELECT
  FileName = REPLACE(subdirectory,'.csv',''),
  FullPath = CONCAT(@path, N'\', subdirectory)
  
FROM #dir
WHERE [file] = 1
  AND subdirectory LIKE '%.csv'  
ORDER BY FileName;
DROP Table #dir
END
