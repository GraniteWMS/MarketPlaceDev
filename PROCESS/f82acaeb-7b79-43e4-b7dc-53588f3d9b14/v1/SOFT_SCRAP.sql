-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 10:08:12
-- Source: SOFT_SCRAP
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_100
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','To Location',100, 'True','True','SCRAP',0,'SOFT_SCRAP','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',0, 'True','True','',0,'SOFT_SCRAP','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','SOFT_SCRAP','SOFT_SCRAP','MOVE', '','False','False','')

-- =============================================
-- END OF SCRIPT
-- =============================================
