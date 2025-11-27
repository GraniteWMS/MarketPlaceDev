-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 10:08:21
-- Source: DATACAPTURE
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('OptionalFieldValue','OptionalFieldValue',2, 'True','True','',3,'DATACAPTURE','','')


-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Confirmation',3, 'True','False','',0,'DATACAPTURE','','')


-- ProcessStep_99
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Print','Print',99, 'False','False','',0,'DATACAPTURE','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','DATACAPTURE','DATACAPTURE','DATACAPTURE', '','False','False','')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',0, 'True','True','',1,'DATACAPTURE','','')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('OptionalField','OptionalField',1, 'True','True','',2,'DATACAPTURE','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
