CREATE VIEW [dbo].[DataGrid_CrateStatistics]
AS


SELECT 
CAST(T.[Date] AS DATE) ProductionDate,
H.DayOfTheWeek,
H.HourOfTheYear,
H.HourOfTheDay,
COUNT(T.ID) CratesProducedInHour,
CAST(CAST(COUNT(T.ID) AS DECIMAL(19, 4)) / ((CAST(ISNULL(NULLIF(DATEDIFF(SECOND, MIN(T.[Date]), MAX(T.[Date])), 0), 1) AS DECIMAL(19, 4))) / 60) AS DECIMAL(19, 2)) NumberOfCratesPerMinute
FROM [Transaction] T 
OUTER APPLY
(SELECT DATEPART(HOUR, T.[Date]) HourOfTheDay,
DATEPART(DAYOFYEAR, T.[Date])*24 + DATEPART(HOUR, T.[Date]) HourOfTheYear,
DATENAME(DW, T.[Date]) DayOfTheWeek) H
OUTER APPLY
(SELECT CAST(DATEADD(MONTH, -2, GETDATE()) AS DATE) StartDate,
CAST(GETDATE() + 1 AS DATE) EndDate) D
WHERE T.[Process] = 'PRODUCTIONSCAN'
AND T.[Date] >= StartDate AND T.[Date] < EndDate
GROUP BY CAST(T.[Date] AS DATE), H.DayOfTheWeek, H.HourOfTheDay, H.HourOfTheYear


