CREATE PROCEDURE WebtemplateSpotCheckSession
@Cage varchar(100) = 'CAGE K'
AS
SELECT 'NEW' AS Session
UNION ALL
SELECT Name as Session
FROM StockTakeSession
WHERE	Name LIKE @Cage + '%'
		AND Active = 1
