-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-09 15:54:39
-- Source: EXAMPLE_EXPORT_SSRSREPORT
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Example','Example',0, 'True','True','',0,'EXAMPLE_EXPORT_SSRSREPORT','Prescript_Example_ExportSsrsReport','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','EXAMPLE_EXPORT_SSRSREPORT','EXAMPLE_EXPORT_SSRSREPORT','CUSTOM', '','False','False','')

-- =============================================
-- END OF SCRIPT
-- =============================================
