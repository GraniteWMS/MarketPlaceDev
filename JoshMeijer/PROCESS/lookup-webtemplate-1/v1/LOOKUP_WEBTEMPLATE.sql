INSERT INTO [Process] ([isActive], [Name], [Description], [Type], [IntegrationMethod], [IntegrationIsActive], [IntegrationPost], [WebTemplate])
VALUES('True', 'LOOKUP_WEBTEMPLATE', 'GENERIC LOOKUP', 'CUSTOM', '', 'False', 'False', '7fc8f460-27eb-530d-bf12-acfda44e32eb')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Scanned','Scan a Barcode',0, 'True','True','',1,'LOOKUP_WEBTEMPLATE','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Result','Press Enter to Restart',1, 'True','False','',0,'LOOKUP_WEBTEMPLATE','','')