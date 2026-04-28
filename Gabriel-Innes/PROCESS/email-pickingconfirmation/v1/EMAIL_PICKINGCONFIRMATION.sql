INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','EMAIL_PICKINGCONFIRMATION','EMAIL_PICKINGCONFIRMATION','CUSTOM', '','False','False','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',0, 'True','True','',1,'EMAIL_PICKINGCONFIRMATION','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Confirm',1, 'True','True','',0,'EMAIL_PICKINGCONFIRMATION','PrescriptEmailPickNotification','')
GO
INSERT INTO [SystemStaticData] ([Key],[Description],[Group],[Value],[isEncrypted]) 
VALUES('PickingConfirmation','List of emails to send the picking confirmation email to. Separate emails with ;','Prescript','email1@gmail.com;email2@gmail.com','False')