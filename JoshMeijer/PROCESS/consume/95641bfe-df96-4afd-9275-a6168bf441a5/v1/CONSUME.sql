-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 10:08:21
-- Source: CONSUME
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',3, 'True','True','',2,'CONSUME','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('UOM','UOM',0, 'False','False','',0,'CONSUME','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Comment','Comment',0, 'False','False','',0,'CONSUME','','')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',2, 'True','True','',3,'CONSUME','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','CONSUME','CONSUME','CONSUME', '','False','False','')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',0, 'True','True','',1,'CONSUME','','')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',1, 'True','True','',2,'CONSUME','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
