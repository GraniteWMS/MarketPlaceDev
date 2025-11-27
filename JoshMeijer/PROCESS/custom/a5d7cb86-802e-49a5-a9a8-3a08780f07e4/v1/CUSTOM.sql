-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 10:08:21
-- Source: CUSTOM
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('CustomStep','CustomStep',0, 'True','True','',0,'CUSTOM','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','CUSTOM','CUSTOM','CUSTOM', '','False','False','')

-- =============================================
-- END OF SCRIPT
-- =============================================
