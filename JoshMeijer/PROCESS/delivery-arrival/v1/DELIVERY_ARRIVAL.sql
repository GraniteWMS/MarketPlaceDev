INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','DELIVERY_ARRIVAL','DELIVERY_ARRIVAL','CUSTOM', '','False','False','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Select Location from Lookup List',0, 'True','True','',1,'DELIVERY_ARRIVAL','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Carrier','Carrier Company',1, 'True','True','',2,'DELIVERY_ARRIVAL','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('VehicleReg','Vehicle Registration',2, 'True','True','',3,'DELIVERY_ARRIVAL','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Driver','Driver Name or Initials',3, 'True','True','',4,'DELIVERY_ARRIVAL','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Reference','Waybill or Container Number',4, 'True','True','',5,'DELIVERY_ARRIVAL','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('PODocument','Purchase Order Document',5, 'True','True','',5,'DELIVERY_ARRIVAL','DELIVERY_ARRIVAL_PODocument','')
GO
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('1-DELIVERYAPRON','1-DELIVERYAPRON','DELIVERY_ARRIVAL', 'Location')