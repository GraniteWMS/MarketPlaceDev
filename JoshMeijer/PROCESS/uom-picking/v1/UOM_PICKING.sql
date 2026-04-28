INSERT INTO [Process] ([isActive], [Name], [Description], [Type], [IntegrationMethod], [IntegrationIsActive], [IntegrationPost], [WebTemplate])
VALUES('True', 'UOM_PICKING', 'PICKING', 'PICKING', '', 'False', 'False', 'e36e9563-4b9a-5a62-874f-358fc8796ddf')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',0, 'True','True','',1,'UOM_PICKING','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',1, 'True','True','',2,'UOM_PICKING','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',2, 'True','True','',3,'UOM_PICKING','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',3, 'True','True','',2,'UOM_PICKING','','')