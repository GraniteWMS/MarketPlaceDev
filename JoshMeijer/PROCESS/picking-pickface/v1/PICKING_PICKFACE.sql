INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','PICKING_PICKFACE','PICKING PICKFACE','PICKING', '','False','False','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',0, 'True','True','',1,'PICKING_PICKFACE','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',1, 'True','True','',2,'PICKING_PICKFACE','PrescriptPickingPickfaceLocation','')
GO
INSERT INTO [ProcessStep] ([Name], [Description], [ProcessIndex], [isActive], [Required], [DefaultValue], [NextIndex], [Process], [PreScript], [WebTemplate])
VALUES('TrackingEntity', 'TrackingEntity', 2, 'True', 'True', '', 3, 'PICKING_PICKFACE', '', '7cb14676-c172-5924-92a9-f536d7ca753e')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',3, 'True','True','',2,'PICKING_PICKFACE','','')