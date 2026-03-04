INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','LOCATION_ITEM_BARCODE_ADJUSTMENT','LOCATION_ITEM_BARCODE_ADJUSTMENT','ADJUSTMENT', '','False','False','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('FromLocation','From Location',0, 'True','True','',1,'LOCATION_ITEM_BARCODE_ADJUSTMENT','PrescriptAdjustment_LOC_MIFromLocation','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','MasterItem',1, 'True','True','',2,'LOCATION_ITEM_BARCODE_ADJUSTMENT','PrescriptAdjustment_LOC_MITrackingEntity','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Type','Type',2, 'True','True','',3,'LOCATION_ITEM_BARCODE_ADJUSTMENT','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',3, 'True','True','',4,'LOCATION_ITEM_BARCODE_ADJUSTMENT','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Confirmation',4, 'True','False','',0,'LOCATION_ITEM_BARCODE_ADJUSTMENT','','')