CREATE VIEW [dbo].[WebTemplate_Users]
AS
SELECT U.[Name] AS UserName, UG.Name AS [Group]
FROM [Users] U
INNER JOIN UserGroup UG ON UG.ID = U.UserGroup_id
WHERE U.isActive = 1
