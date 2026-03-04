IF NOT EXISTS(SELECT * FROM EmailTemplate WHERE Name = 'PickingNotification')
	BEGIN
		INSERT INTO EmailTemplate (Name, Description, Definition, Format, AuditDate, AuditUser, Version)
		SELECT	'PickingNotification', 
				'Notification of picking', 
				'{{     headerImage(     {       imageUrl:''https://www.granitewms.com/wp-content/uploads/2020/07/GraniteWMS-1.png'',       imageAltText:''GraniteWMS logo'',       backgroundColor:''#182026''     }) }}  Order **{{documentNumber}}** has been picked.  {{         ''SELECT Code, Description, OrderedQty, PickedQty, Comment FROM EmailTemplatePickedLines WHERE DocumentNumber = @documentNumber''     | dbSelect({documentNumber})     | table({backgroundColor: ''#182026'', textColor: ''white'', sumColumns:[''PickedQty'', ''OrderedQty'']}) }}',
				'markdown',
				GETDATE(),
				'Custodian',
				1
	END
GO