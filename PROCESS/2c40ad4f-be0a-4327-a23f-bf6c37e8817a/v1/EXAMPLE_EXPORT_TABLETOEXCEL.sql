-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 10:08:12
-- Source: EXAMPLE_EXPORT_TABLETOEXCEL
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Example','Example',0, 'True','True','',0,'EXAMPLE_EXPORT_TABLETOEXCEL','Prescript_Example_ExportExcelFile','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','EXAMPLE_EXPORT_TABLETOEXCEL','EXAMPLE_EXPORT_TABLETOEXCEL','CUSTOM', '','False','False','')

-- =============================================
-- END OF SCRIPT
-- =============================================
