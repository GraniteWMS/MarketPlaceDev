INSERT INTO [Process] ([isActive], [Name], [Description], [Type], [IntegrationMethod], [IntegrationIsActive], [IntegrationPost], [WebTemplate])
VALUES('True', 'REPLENISH_PICKFACE', 'REPLENISH PICKFACE', 'CUSTOM', '', 'False', 'False', '0bd844d2-53a1-593a-85ba-c63974309e0d')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('FromTrackingEntity','From Barcode',0, 'True','True','',1,'REPLENISH_PICKFACE','PrescriptReplenishPickfaceFromTrackingEntity','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','To Location',1, 'True','True','',2,'REPLENISH_PICKFACE','PrescriptReplenishPickfaceLocation','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty to Replenish',2, 'True','True','',1,'REPLENISH_PICKFACE','PrescriptReplenishPickfaceQty','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Step200','Step200',200, 'True','True','',0,'REPLENISH_PICKFACE','PrescriptReplenishPickfaceStep200','')