CREATE VIEW [dbo].[Datagrid_TaskList]
AS
SELECT TaskName,TaskDescription,U.Name AS [User],TE.Barcode as TrackingEntity ,L.Name as Location, CTL.Status
FROM Custom_TaskList CTL
INNER JOIN Users U ON CTL.UserID = U.ID
LEFT JOIN TrackingEntity TE ON CTL.TrackingEntityID = TE.ID
LEFT JOIN Location L ON CTL.LocationID = L.ID
GO

GO