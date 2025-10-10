-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 07:08:04
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','ADJUSTMENT','ADJUSTMENT','ADJUSTMENT', '','False','False','')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Reference','Reference',0, 'True','False','',1,'ADJUSTMENT','','')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',1, 'True','True','',2,'ADJUSTMENT','','')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Type','Type',2, 'True','True','',3,'ADJUSTMENT','','')


-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',3, 'True','True','',4,'ADJUSTMENT','','')


-- ProcessStep_4
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Comment','Comment',4, 'True','False','',5,'ADJUSTMENT','','')


-- ProcessStep_5
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Confirmation',5, 'True','False','',1,'ADJUSTMENT','','')


-- ProcessStepLookup_0
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('CORRECT TO PHYSICAL','CORRECT TO PHYSICAL','ADJUSTMENT', 'Comment')


-- ProcessStepLookup_1
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('DAMAGED STOCK','DAMAGED STOCK','ADJUSTMENT', 'Comment')


-- ProcessStepLookup_2
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('EXPIRED STOCK','EXPIRED STOCK','ADJUSTMENT', 'Comment')


-- ProcessStepLookup_3
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('INCORRECT LABEL','INCORRECT LABEL','ADJUSTMENT', 'Comment')


-- ProcessStepLookup_4
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('PROCESS ERROR','PROCESS ERROR','ADJUSTMENT', 'Comment')


-- =============================================
-- END OF SCRIPT
-- =============================================
