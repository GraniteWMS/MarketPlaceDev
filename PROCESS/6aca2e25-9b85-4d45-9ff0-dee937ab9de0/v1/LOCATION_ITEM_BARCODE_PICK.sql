-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 10:08:12
-- Source: LOCATION_ITEM_BARCODE_PICK
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('MasterItem','MasterItem',1, 'True','True','',2,'LOCATION_ITEM_BARCODE_PICK','PrescriptLOCATION_ITEM_BARCODE_PICKMasterItem','')


-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',3, 'True','True','',1,'LOCATION_ITEM_BARCODE_PICK','','')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','From Location',2, 'True','True','',3,'LOCATION_ITEM_BARCODE_PICK','PrescriptLOCATION_ITEM_BARCODE_PICKTrackingEntity','{{ "SELECT LocationName, Qty FROM WebTemplate_LOCATION_ITEM_BARCODE_PICKING_TrackingEntity WHERE Code = @MasterItem" | dbSelect({MasterItem}) | basicTable({}) }}')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','LOCATION_ITEM_BARCODE_PICK','PICKING','PICKING', '','False','False','')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',0, 'True','True','',1,'LOCATION_ITEM_BARCODE_PICK','','')


-- ProcessStep_100
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',100, 'True','True','DIS',2,'LOCATION_ITEM_BARCODE_PICK','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
