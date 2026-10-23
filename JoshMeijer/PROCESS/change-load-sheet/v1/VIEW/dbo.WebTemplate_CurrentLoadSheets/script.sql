CREATE VIEW [dbo].[WebTemplate_CurrentLoadSheets]
AS
SELECT DISTINCT DocumentReference AS LoadSheet
FROM [Transaction] TR
WHERE TR.Process = 'LOADPREP'
 AND CONVERT(Date,[Date]) = CONVERT(date,GETDATE())
