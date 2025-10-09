-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-09 15:54:39
-- Source: LOCATION_ITEM_BARCODE_STOCKTAKE
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',2, 'True','True','',3,'LOCATION_ITEM_BARCODE_STOCKTAKE','PrescriptStockTakeCount_LOC_MILocation','')


-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','MasterItem',3, 'True','False','',4,'LOCATION_ITEM_BARCODE_STOCKTAKE','PrescriptStockTakeCount_LOC_MITrackingEntity','')


-- ProcessStep_4
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',4, 'True','False','',2,'LOCATION_ITEM_BARCODE_STOCKTAKE','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','LOCATION_ITEM_BARCODE_STOCKTAKE','LOCATION_ITEM_BARCODE_STOCKTAKE','STOCKTAKECOUNT', '','False','False','')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Session','Session',0, 'True','False','',1,'LOCATION_ITEM_BARCODE_STOCKTAKE','','')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Count','Count',1, 'True','True','',2,'LOCATION_ITEM_BARCODE_STOCKTAKE','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
