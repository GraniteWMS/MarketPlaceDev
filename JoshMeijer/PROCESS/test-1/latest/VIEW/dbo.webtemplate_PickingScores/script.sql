CREATE VIEW [dbo].[webtemplate_PickingScores]
AS
SELECT        TOP (100) PERCENT Date, Name, [Pick Transactions]
FROM            (SELECT        CONVERT(varchar(10), TX.Date, 101) AS Date, dbo.Users.Name, COUNT(TX.ID) AS [Pick Transactions]
                          FROM            dbo.[Transaction] AS TX INNER JOIN
                                                    dbo.Users ON TX.User_id = dbo.Users.ID
                          WHERE        (TX.Type = 'PICK') AND (TX.Date > GETDATE() - 7) and Users.Name <> '0'
                          GROUP BY CONVERT(varchar(10), TX.Date, 101), dbo.Users.Name) AS TSQL
ORDER BY Date
