-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-09 15:54:39
-- Source: LOCATION_ITEM_BARCODE_TAKEON
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',2, 'True','True','',1,'LOCATION_ITEM_BARCODE_TAKEON','PrescriptTakeon_LOC_MIQty','')


-- ProcessStep_100
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('UseBarcode','UseBarcode',100, 'True','False','',0,'LOCATION_ITEM_BARCODE_TAKEON','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',0, 'True','True','',1,'LOCATION_ITEM_BARCODE_TAKEON','PrescriptTakeon_LOC_MILocation','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','LOCATION_ITEM_BARCODE_TAKEON','LOCATION_ITEM_BARCODE_TAKEON','TAKEON', '','False','False','')

-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('MasterItem','MasterItem',1, 'True','True','',2,'LOCATION_ITEM_BARCODE_TAKEON','PrescriptTakeon_LOC_MIMasterItem','')


-- =============================================
-- END OF SCRIPT
-- =============================================
