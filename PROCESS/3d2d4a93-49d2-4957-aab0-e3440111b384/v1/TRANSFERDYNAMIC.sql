-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 07:32:40
-- Source: TRANSFERDYNAMIC
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',2, 'True','False','',3,'TRANSFERDYNAMIC','','')


-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',3, 'True','False','',1,'TRANSFERDYNAMIC','','')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('DestinationLocation','DestinationLocation',1, 'True','False','',2,'TRANSFERDYNAMIC','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','TRANSFERDYNAMIC','TRANSFERDYNAMIC','TRANSFERDYNAMIC', '','False','False','')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',0, 'True','False','',1,'TRANSFERDYNAMIC','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
