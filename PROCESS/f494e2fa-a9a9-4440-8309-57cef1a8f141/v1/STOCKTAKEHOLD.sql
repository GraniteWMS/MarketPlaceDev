-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 07:32:40
-- Source: STOCKTAKEHOLD
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Comment','Comment',1, 'True','False','',0,'STOCKTAKEHOLD','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',0, 'True','True','',1,'STOCKTAKEHOLD','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','STOCKTAKEHOLD','STOCKTAKEHOLD','STOCKTAKEHOLD', '','False','False','')

-- =============================================
-- END OF SCRIPT
-- =============================================
