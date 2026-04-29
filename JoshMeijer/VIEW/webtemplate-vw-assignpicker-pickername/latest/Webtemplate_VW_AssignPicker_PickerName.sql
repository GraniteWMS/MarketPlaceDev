CREATE VIEW [dbo].[Webtemplate_VW_AssignPicker_PickerName]
AS
	
	SELECT UPPER(U.Name) [Name]
		  ,UPPER(U.FirstName) FirstName
		  ,UPPER(U.LastName) LastName  
	FROM Users U 
	INNER JOIN UserGroup UG ON UG.ID = U.UserGroup_id AND UPPER(UG.Name) LIKE '%PICK%' 
	WHERE isActive = 1 
