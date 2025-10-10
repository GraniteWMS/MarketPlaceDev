-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 07:32:33
-- Source: EXAMPLE_EMAIL_SSRSATTACHMENT
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Example','Example',0, 'True','True','',0,'EXAMPLE_EMAIL_SSRSATTACHMENT','Prescript_Example_SendEmailWithSsrsReport','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','EXAMPLE_EMAIL_SSRSATTACHMENT','EXAMPLE_EMAIL_SSRSATTACHMENT','CUSTOM', '','False','False','')

-- =============================================
-- END OF SCRIPT
-- =============================================
