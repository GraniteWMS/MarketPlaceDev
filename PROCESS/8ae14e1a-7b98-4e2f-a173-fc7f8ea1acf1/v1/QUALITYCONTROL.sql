-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-09 15:54:53
-- Source: QUALITYCONTROL
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStepsLookup_1
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('DAMAGED STOCK','DAMAGED STOCK','QUALITYCONTROL', 'Comment')


-- ProcessStepsLookup_0
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('QC PROCESS','QC PROCESS','QUALITYCONTROL', 'Comment')


-- ProcessStepsLookup_2
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('EXPIRED STOCK','EXPIRED STOCK','QUALITYCONTROL', 'Comment')


-- ProcessStepsLookup_4
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('PROCESS ERROR','PROCESS ERROR','QUALITYCONTROL', 'Comment')


-- ProcessStepsLookup_3
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('SHORT DATED STOCK','SHORT DATED STOCK','QUALITYCONTROL', 'Comment')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Confirmation',0, 'False','False','',0,'QUALITYCONTROL','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Type','Type',0, 'True','True','',1,'QUALITYCONTROL','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','QUALITYCONTROL','QUALITYCONTROL','QUALITYCONTROL', '','False','False','')

-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Comment','Comment',1, 'True','False','',2,'QUALITYCONTROL','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Reference','Reference',0, 'False','False','',0,'QUALITYCONTROL','','')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',2, 'True','True','',2,'QUALITYCONTROL','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
