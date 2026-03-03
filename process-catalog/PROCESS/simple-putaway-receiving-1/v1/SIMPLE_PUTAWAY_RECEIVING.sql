INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','SIMPLE_PUTAWAY_RECEIVING','SIMPLE_PUTAWAY_RECEIVING','RECEIVING', '','False','False','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',0, 'True','True','',1,'SIMPLE_PUTAWAY_RECEIVING','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('MasterItem','MasterItem',1, 'True','True','',2,'SIMPLE_PUTAWAY_RECEIVING','PrescriptReceivingPutawayMasterItem','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Receiving Location',100, 'True','False','',1,'SIMPLE_PUTAWAY_RECEIVING','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',2, 'True','True','',3,'SIMPLE_PUTAWAY_RECEIVING','PrescriptReceivingPutawayQty','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('NoEntities','Number of TrackingEntities',3, 'True','False','',1,'SIMPLE_PUTAWAY_RECEIVING','','')