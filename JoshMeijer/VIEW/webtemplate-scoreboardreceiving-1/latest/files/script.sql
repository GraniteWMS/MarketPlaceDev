CREATE VIEW [dbo].[webtemplate_ScoreboardReceiving]
AS
SELECT        TOP (100) PERCENT Date, Name, [Received Pallets]
FROM            (SELECT        CONVERT(varchar(10), TX.Date, 101) AS Date, dbo.Users.Name, COUNT(TX.ID) AS [Received Pallets]
                          FROM            dbo.[Transaction] AS TX INNER JOIN
                                                    dbo.Users ON TX.User_id = dbo.Users.ID
                          WHERE         ( (TX.Type = 'RECEIVE') OR (TX.Process = '3PL_RECEIVING'))  
						   AND DATEDIFF(DAY,TX.Date,getdate()) <3
						  and Users.Name <> '0'
                          GROUP BY CONVERT(varchar(10), TX.Date, 101), dbo.Users.Name) AS TSQL
ORDER BY Date
