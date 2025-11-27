-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 10:08:21
-- Source: RETURNPOST
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',0, 'True','True','',0,'RETURNPOST','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','RETURNPOST','RETURNPOST','RETURNPOST', '','False','False','')

-- =============================================
-- END OF SCRIPT
-- =============================================
