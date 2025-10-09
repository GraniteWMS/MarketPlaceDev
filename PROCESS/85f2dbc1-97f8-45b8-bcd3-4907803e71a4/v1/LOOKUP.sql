-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-09 15:54:53
-- Source: LOOKUP
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('LookupValue','LookupValue',1, 'True','True','',1,'LOOKUP','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Type','Type',0, 'True','True','',1,'LOOKUP','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','LOOKUP','LOOKUP','LOOKUP', '','False','False','')

-- =============================================
-- END OF SCRIPT
-- =============================================
