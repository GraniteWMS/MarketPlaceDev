-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 10:08:21
-- Source: RETURN
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStepsLookup_0
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('GOOD STOCK','GOOD STOCK','RETURN', 'Comment')


-- ProcessStepsLookup_1
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('EXPIRED STOCK','EXPIRED STOCK','RETURN', 'Comment')


-- ProcessStepsLookup_2
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('SHORT DATED','SHORT DATED','RETURN', 'Comment')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('UOM','UOM',0, 'False','False','',0,'RETURN','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('ManufactureDate','ManufactureDate',0, 'False','False','',0,'RETURN','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('IntegrationReference','IntegrationReference',0, 'False','False','',0,'RETURN','','')


-- ProcessStepsLookup_6
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('DAMAGED STOCK -DESTROY','DAMAGED STOCK -DESTROY','RETURN', 'Comment')


-- ProcessStepsLookup_7
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('DAMAGED PACKAGING  -DESTROY','DAMAGED PACKAGING  -DESTROY','RETURN', 'Comment')


-- ProcessStepsLookup_8
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('DESTROY','DESTROY','RETURN', 'Comment')


-- ProcessStepsLookup_3
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('RECALLED STOCK','RECALLED STOCK','RETURN', 'Comment')


-- ProcessStepsLookup_4
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('DAMAGED PACKAGING -REPACK','DAMAGED PACKAGING -REPACK','RETURN', 'Comment')


-- ProcessStepsLookup_5
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('RECOVERABLE CONTENT','RECOVERABLE CONTENT','RETURN', 'Comment')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('MasterItem','MasterItem',2, 'True','True','',3,'RETURN','','')


-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Batch','Batch',3, 'True','False','',4,'RETURN','','')


-- ProcessStep_4
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('ExpiryDate','ExpiryDate (YYYYMMDD)',4, 'True','False','',5,'RETURN','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','RETURN','RETURN','RETURN', '','False','False','')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Reference','Return Reference',0, 'True','False','',1,'RETURN','','')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Return Location',1, 'True','True','',2,'RETURN','','')


-- ProcessStep_99
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Print','Print',99, 'True','False','',0,'RETURN','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('CarryingEntity','CarryingEntity',0, 'False','False','',0,'RETURN','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('SerialNumber','SerialNumber',0, 'False','False','',0,'RETURN','','')


-- ProcessStep_5
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Comment','Select Comment',5, 'True','False','',6,'RETURN','','')


-- ProcessStep_6
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('UseBarcode','TO Tracking Barcode (Blank for NEW)',6, 'True','False','',7,'RETURN','','')


-- ProcessStep_7
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',7, 'True','True','',2,'RETURN','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
