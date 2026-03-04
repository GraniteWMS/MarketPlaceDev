INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','COMPLETE_DOCUMENT_PICKINGPOST','PICKINGPOST','PICKINGPOST', '','False','False','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',0, 'True','True','',0,'COMPLETE_DOCUMENT_PICKINGPOST','PrescriptCompletePickingPostDocument','')