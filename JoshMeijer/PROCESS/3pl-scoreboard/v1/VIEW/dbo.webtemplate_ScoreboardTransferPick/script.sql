CREATE VIEW [dbo].[webtemplate_ScoreboardTransferPick]
AS
SELECT        TOP (100) PERCENT Date, Name, [Transfer Picks]
FROM            (SELECT        CONVERT(varchar(10), TX.Date, 101) AS Date, dbo.Users.Name, COUNT(TX.ID) AS  [Transfer Picks]
                          FROM            dbo.[Transaction] AS TX INNER JOIN
                                                    dbo.Users ON TX.User_id = dbo.Users.ID
                          WHERE        (TX.Type = 'TRANSFER') 
						  AND DATEDIFF(DAY,TX.Date,getdate()) <3
						  AND Users.Name <> '0'
                          GROUP BY CONVERT(varchar(10), TX.Date, 101), dbo.Users.Name) AS TSQL
ORDER BY Date
