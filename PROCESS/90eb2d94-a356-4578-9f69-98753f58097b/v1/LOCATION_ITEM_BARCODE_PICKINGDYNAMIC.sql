-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-09 15:54:39
-- Source: LOCATION_ITEM_BARCODE_PICKINGDYNAMIC
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('MasterItem','MasterItem',1, 'True','True','',2,'LOCATION_ITEM_BARCODE_PICKINGDYNAMIC','PrescriptPickingDynamic_LOC_MIMasterItem','')


-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',3, 'True','True','',1,'LOCATION_ITEM_BARCODE_PICKINGDYNAMIC','','')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','From Location',2, 'True','True','',3,'LOCATION_ITEM_BARCODE_PICKINGDYNAMIC','PrescriptPickingDynamic_LOC_MITrackingEntity','{{ "SELECT LocationName, Qty FROM WebTemplate_PickingDynamicLocMI_TrackingEntity WHERE Code = @MasterItem" | dbSelect({MasterItem}) | basicTable({}) }}')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','LOCATION_ITEM_BARCODE_PICKINGDYNAMIC','LOCATION_ITEM_BARCODE_PICKINGDYNAMIC','PICKINGDYNAMIC', '','False','False','')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',0, 'True','True','',1,'LOCATION_ITEM_BARCODE_PICKINGDYNAMIC','PrescriptPickingDynamic_LOC_MIDocument','')


-- ProcessStep_100
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',100, 'True','True','DIS',2,'LOCATION_ITEM_BARCODE_PICKINGDYNAMIC','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
