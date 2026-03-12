INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','SCRAP_WITH_REASON','SCRAP','SCRAP', '','True','False','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Reference','Reason',0, 'True','False','',1,'SCRAP_WITH_REASON','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Comment','Details',1, 'True','False','',2,'SCRAP_WITH_REASON','Prescript_ScrapBarcode_Comment','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','Scan Barcode',2, 'True','True','',3,'SCRAP_WITH_REASON','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Are You Sure?',3, 'True','False','',0,'SCRAP_WITH_REASON','','')
GO
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('Stolen','Stolen','SCRAP_WITH_REASON', 'Reference')
GO
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('Damaged','Damaged','SCRAP_WITH_REASON', 'Reference')
GO
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('Other','Other','SCRAP_WITH_REASON', 'Reference')