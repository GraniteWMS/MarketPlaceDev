-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-09 15:54:53
-- Source: PICKINGDYNAMICPOST
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',0, 'True','True','',0,'PICKINGDYNAMICPOST','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','PICKINGDYNAMICPOST','PICKINGDYNAMICPOST','PICKINGDYNAMICPOST', '','False','False','')

-- =============================================
-- END OF SCRIPT
-- =============================================
