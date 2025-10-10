-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 10:08:12
-- Source: COMPLETE_DOCUMENT_PICKINGPOST
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',0, 'True','True','',0,'COMPLETE_DOCUMENT_PICKINGPOST','PrescriptCompletePickingPostDocument','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','COMPLETE_DOCUMENT_PICKINGPOST','PICKINGPOST','PICKINGPOST', '','False','False','')

-- =============================================
-- END OF SCRIPT
-- =============================================
