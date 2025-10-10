-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 07:32:40
-- Source: SCRAP
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStepsLookup_1
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('DAMAGED STOCK','DAMAGED STOCK','SCRAP', 'Comment')


-- ProcessStepsLookup_0
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('MISSING STOCK','MISSING STOCK','SCRAP', 'Comment')


-- ProcessStepsLookup_2
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('EXPIRED STOCK','EXPIRED STOCK','SCRAP', 'Comment')


-- ProcessStepsLookup_4
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('PROCESS ERROR','PROCESS ERROR','SCRAP', 'Comment')


-- ProcessStepsLookup_3
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('INCORRECT LABEL','INCORRECT LABEL','SCRAP', 'Comment')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('IntegrationReference','IntegrationReference',0, 'False','False','',0,'SCRAP','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Reference','Reference',0, 'True','False','',1,'SCRAP','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','SCRAP','SCRAP','SCRAP', '','False','False','')

-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',1, 'True','True','',2,'SCRAP','','')


-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Continue with scrap transaction?',3, 'True','False','',1,'SCRAP','','')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Comment','Select Scrap Reason',2, 'True','False','',3,'SCRAP','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
