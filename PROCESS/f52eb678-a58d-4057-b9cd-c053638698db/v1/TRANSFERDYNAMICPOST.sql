-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 07:32:40
-- Source: TRANSFERDYNAMICPOST
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',0, 'True','True','',0,'TRANSFERDYNAMICPOST','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','TRANSFERDYNAMICPOST','TRANSFERDYNAMICPOST','TRANSFERPOST', 'DYNAMICTRANSFER','False','False','')

-- =============================================
-- END OF SCRIPT
-- =============================================
