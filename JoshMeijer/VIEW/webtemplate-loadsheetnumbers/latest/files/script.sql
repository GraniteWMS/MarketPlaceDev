CREATE VIEW [dbo].[WebTemplate_LoadSheetNumbers]
AS
SELECT DISTINCT DocumentReference AS LoadNumber
FROM [Transaction] TR
WHERE [Process] = 'LOADPREP'
  AND DATEDIFF(DAY,[Date],GETDATE()) <= 3
