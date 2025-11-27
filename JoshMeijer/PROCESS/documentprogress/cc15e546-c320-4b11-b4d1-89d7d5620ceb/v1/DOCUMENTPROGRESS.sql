-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 10:08:21
-- Source: DOCUMENTPROGRESS
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('FilterDocument','Filter Document',1, 'True','True','',1,'DOCUMENTPROGRESS','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Type','Document Type',0, 'True','True','',1,'DOCUMENTPROGRESS','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','DOCUMENTPROGRESS','DOCUMENTPROGRESS','DOCUMENTPROGRESS', '','False','False','')

-- =============================================
-- END OF SCRIPT
-- =============================================
