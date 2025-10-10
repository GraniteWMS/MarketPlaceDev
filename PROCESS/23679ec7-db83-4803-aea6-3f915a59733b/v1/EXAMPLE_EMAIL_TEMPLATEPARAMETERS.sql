-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 07:32:33
-- Source: EXAMPLE_EMAIL_TEMPLATEPARAMETERS
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Example','Example',0, 'True','True','',0,'EXAMPLE_EMAIL_TEMPLATEPARAMETERS','Prescript_Example_SendTemplateEmailWithParameters','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','EXAMPLE_EMAIL_TEMPLATEPARAMETERS','EXAMPLE_EMAIL_TEMPLATEPARAMETERS','CUSTOM', '','False','False','')

-- =============================================
-- END OF SCRIPT
-- =============================================
