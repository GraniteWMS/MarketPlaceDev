-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 10:08:12
-- Source: EXAMPLE_EMAIL_FILEATTACHMENTS
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Example','Example',0, 'True','True','',0,'EXAMPLE_EMAIL_FILEATTACHMENTS','Prescript_Example_SendEmailWithFileAttachments','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','EXAMPLE_EMAIL_FILEATTACHMENTS','EXAMPLE_EMAIL_FILEATTACHMENTS','CUSTOM', '','False','False','')

-- =============================================
-- END OF SCRIPT
-- =============================================
