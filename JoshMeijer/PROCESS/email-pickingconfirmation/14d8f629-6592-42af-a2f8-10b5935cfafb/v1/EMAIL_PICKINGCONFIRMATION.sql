-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 10:08:12
-- Source: EMAIL_PICKINGCONFIRMATION
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Confirm',1, 'True','True','',0,'EMAIL_PICKINGCONFIRMATION','PrescriptEmailPickNotification','')


-- SystemStaticData_PickingConfirmation
INSERT INTO [SystemStaticData] ([Key],[Description],[Group],[Value],[isEncrypted]) 
VALUES('PickingConfirmation','List of emails to send the picking confirmation email to. Separate emails with ;','Prescript','email1@gmail.com;email2@gmail.com','False')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','EMAIL_PICKINGCONFIRMATION','EMAIL_PICKINGCONFIRMATION','CUSTOM', '','False','False','')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',0, 'True','True','',1,'EMAIL_PICKINGCONFIRMATION','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
