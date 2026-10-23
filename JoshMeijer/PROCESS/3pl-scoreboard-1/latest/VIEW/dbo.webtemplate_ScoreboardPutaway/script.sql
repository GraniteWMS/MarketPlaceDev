CREATE VIEW [dbo].[webtemplate_ScoreboardPutaway]
AS
SELECT        TOP (100) PERCENT Date, Name, [Putaway Transactions]
FROM            (SELECT        CONVERT(varchar(10), TX.Date, 101) AS Date, dbo.Users.Name, COUNT(TX.ID) AS [Putaway Transactions]
                          FROM            dbo.[Transaction] AS TX INNER JOIN
                                                    dbo.Users ON TX.User_id = dbo.Users.ID
                          WHERE         ( (TX.Type = 'MOVE') OR (TX.Process = '3PL_PUTAWAY')) 
						  AND DATEDIFF(DAY,TX.Date,getdate()) <3
						  and Users.Name <> '0'
                          GROUP BY CONVERT(varchar(10), TX.Date, 101), dbo.Users.Name) AS TSQL
ORDER BY Date
