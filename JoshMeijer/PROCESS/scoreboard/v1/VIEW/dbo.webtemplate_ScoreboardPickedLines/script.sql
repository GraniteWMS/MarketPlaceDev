CREATE VIEW [dbo].[webtemplate_ScoreboardPickedLines]
AS
SELECT        TOP (100) PERCENT Date, Name, [Picked Lines]
FROM            (SELECT        CONVERT(varchar(10), TX.Date, 101) AS Date, dbo.Users.Name, COUNT(TX.ID) AS  [Picked Lines]
                          FROM            dbo.[Transaction] AS TX INNER JOIN
                                                    dbo.Users ON TX.User_id = dbo.Users.ID
                          WHERE        (TX.Type = 'PICK') 
						  AND DATEDIFF(DAY,TX.Date,getdate()) <3
						  AND Users.Name <> '0'
						  and ReversalTransaction_id = 0
                          GROUP BY CONVERT(varchar(10), TX.Date, 101), dbo.Users.Name) AS TSQL
ORDER BY Date
