INSERT INTO [Process] ([isActive], [Name], [Description], [Type], [IntegrationMethod], [IntegrationIsActive], [IntegrationPost], [WebTemplate])
VALUES('True', 'CARRYINGENTITY_CONTENTS_LOOKUP', 'CARRYINGENTITY_CONTENTS_LOOKUP', 'CUSTOM', '', 'False', 'False', '3b7781a4-27cb-5b75-b7fc-549ad324c167')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Barcode','Carrying Entity Barcode',0, 'True','True','',1,'CARRYINGENTITY_CONTENTS_LOOKUP','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Confirm',1, 'True','True','',0,'CARRYINGENTITY_CONTENTS_LOOKUP','','')