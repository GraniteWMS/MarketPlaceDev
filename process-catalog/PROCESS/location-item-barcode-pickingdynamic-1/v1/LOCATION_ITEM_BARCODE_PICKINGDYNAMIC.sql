INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','LOCATION_ITEM_BARCODE_PICKINGDYNAMIC','LOCATION_ITEM_BARCODE_PICKINGDYNAMIC','PICKINGDYNAMIC', '','False','False','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',0, 'True','True','',1,'LOCATION_ITEM_BARCODE_PICKINGDYNAMIC','PrescriptPickingDynamic_LOC_MIDocument','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('MasterItem','MasterItem',1, 'True','True','',2,'LOCATION_ITEM_BARCODE_PICKINGDYNAMIC','PrescriptPickingDynamic_LOC_MIMasterItem','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',100, 'True','True','DIS',2,'LOCATION_ITEM_BARCODE_PICKINGDYNAMIC','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','From Location',2, 'True','True','',3,'LOCATION_ITEM_BARCODE_PICKINGDYNAMIC','PrescriptPickingDynamic_LOC_MITrackingEntity','{{ "SELECT LocationName, Qty FROM WebTemplate_PickingDynamicLocMI_TrackingEntity WHERE Code = @MasterItem" | dbSelect({MasterItem}) | basicTable({}) }}')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',3, 'True','True','',1,'LOCATION_ITEM_BARCODE_PICKINGDYNAMIC','','')