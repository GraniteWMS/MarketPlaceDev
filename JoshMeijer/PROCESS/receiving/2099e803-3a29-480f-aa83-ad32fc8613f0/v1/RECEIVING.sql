-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 10:08:21
-- Source: RECEIVING
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('ManufactureDate','ManufactureDate (YYYYMMDD)',0, 'False','False','',0,'RECEIVING','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Confirmation',0, 'False','False','',0,'RECEIVING','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('SerialNumber','SerialNumber',0, 'False','False','',0,'RECEIVING','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('IntegrationReference','IntegrationReference',0, 'False','False','',0,'RECEIVING','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Reference','Reference',0, 'False','False','',0,'RECEIVING','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('UOM','UOM',0, 'False','False','',0,'RECEIVING','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('UseBarcode','UseBarcode',0, 'False','False','',0,'RECEIVING','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Comment','Comment',0, 'False','False','',0,'RECEIVING','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('CarryingEntity','CarryingEntity',0, 'False','False','',0,'RECEIVING','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('NoLabels','Number of Label Copies',0, 'False','False','',0,'RECEIVING','','')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',1, 'True','True','',2,'RECEIVING','','')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('MasterItem','MasterItem',2, 'True','True','',3,'RECEIVING','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','RECEIVING','RECEIVING','RECEIVING', '','False','False','')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Receiving Location',0, 'True','False','',1,'RECEIVING','','')


-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Batch','Batch',3, 'True','False','',4,'RECEIVING','','')


-- ProcessStep_6
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('NoEntities','Number of TrackingEntities',6, 'True','False','',2,'RECEIVING','','')


-- ProcessStep_99
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Print','Print',99, 'True','True','',0,'RECEIVING','','')


-- ProcessStep_4
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('ExpiryDate','ExpiryDate (YYYYMMDD)',4, 'True','False','',5,'RECEIVING','','')


-- ProcessStep_5
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',5, 'True','True','',6,'RECEIVING','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
