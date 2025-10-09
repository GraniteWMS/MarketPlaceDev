-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-09 15:54:39
-- Source: LOCATION_ITEM_BARCODE_SCRAP
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Confirmation',3, 'True','False','',0,'LOCATION_ITEM_BARCODE_SCRAP','','')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty to Replenish',2, 'True','True','',3,'LOCATION_ITEM_BARCODE_SCRAP','','')


-- ProcessStep_200
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Step200','Step200',200, 'True','True','',200,'LOCATION_ITEM_BARCODE_SCRAP','PrescriptLOCATION_ITEM_BARCODE_SCRAPStep200','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('FromLocation','From Location',0, 'True','True','',1,'LOCATION_ITEM_BARCODE_SCRAP','PrescriptLOCATION_ITEM_BARCODE_SCRAPFromLocation','')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('FromTrackingEntity','MasterItem',1, 'True','True','',2,'LOCATION_ITEM_BARCODE_SCRAP','PrescriptLOCATION_ITEM_BARCODE_SCRAPTrackingEntity','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','LOCATION_ITEM_BARCODE_SCRAP','SCRAP','REPLENISH', '','False','False','')

-- ProcessStep_100
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('ToTrackingEntity','To TrackingEntity',100, 'True','False','',100,'LOCATION_ITEM_BARCODE_SCRAP','','')


-- ProcessStep_100
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','To Location',100, 'True','True','SCRAP',100,'LOCATION_ITEM_BARCODE_SCRAP','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
