CREATE VIEW [dbo].[Webtemplate_TaskList]
AS
	SELECT CTL.TaskName, CTL.TaskDescription, TE.Barcode, L.Name AS [Location]
	FROM Custom_TaskList CTL
	LEFT JOIN TrackingEntity TE ON TE.ID = CTL.TrackingEntityID
	LEFT JOIN [Location] L ON L.ID = CTL.LocationID
	WHERE CTL.[Status] = 'ACTIVE'
