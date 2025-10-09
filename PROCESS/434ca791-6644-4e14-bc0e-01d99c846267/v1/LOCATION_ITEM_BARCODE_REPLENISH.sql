-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-09 15:54:39
-- Source: LOCATION_ITEM_BARCODE_REPLENISH
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_4
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('ToTrackingEntity','ToTrackingEntity',4, 'True','True','',0,'LOCATION_ITEM_BARCODE_REPLENISH','PrescriptReplenish_LOC_MIToTrackingEntity','')


-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty to Replenish',3, 'True','True','',4,'LOCATION_ITEM_BARCODE_REPLENISH','PrescriptReplenish_LOC_MIQty','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('FromLocation','From Location',0, 'True','True','',1,'LOCATION_ITEM_BARCODE_REPLENISH','PrescriptReplenish_LOC_MIFromLocation','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','LOCATION_ITEM_BARCODE_REPLENISH','LOCATION_ITEM_BARCODE_REPLENISH','REPLENISH', '','False','False','')

-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('FromTrackingEntity','MasterItem',1, 'True','True','',2,'LOCATION_ITEM_BARCODE_REPLENISH','PrescriptReplenish_LOC_MIFromTrackingEntity','')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','To Location',2, 'True','True','',3,'LOCATION_ITEM_BARCODE_REPLENISH','PrescriptReplenish_LOC_MILocation','')


-- =============================================
-- END OF SCRIPT
-- =============================================
