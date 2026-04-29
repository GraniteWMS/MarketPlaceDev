INSERT INTO [Process] ([isActive], [Name], [Description], [Type], [IntegrationMethod], [IntegrationIsActive], [IntegrationPost], [WebTemplate])
VALUES('True', 'LOOKUP_WITH_IMAGES', 'LOOKUP WITH IMAGES', 'LOOKUP', '', 'False', 'False', '95061f69-1d2d-535f-b7be-57d5c56f683a')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Type','Type',0, 'True','True','',1,'LOOKUP_WITH_IMAGES','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('LookupValue','LookupValue',1, 'True','True','',2,'LOOKUP_WITH_IMAGES','','')
GO
INSERT INTO [ProcessStep] ([Name], [Description], [ProcessIndex], [isActive], [Required], [DefaultValue], [NextIndex], [Process], [PreScript], [WebTemplate])
VALUES('Confirmation', 'Confirm', 2, 'True', 'True', '', 1, 'LOOKUP_WITH_IMAGES', '', '5b79e35d-1fe4-518d-b429-3acd200984dc')