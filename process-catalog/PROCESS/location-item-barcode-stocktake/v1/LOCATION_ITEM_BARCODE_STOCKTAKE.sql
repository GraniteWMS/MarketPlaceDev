INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','LOCATION_ITEM_BARCODE_STOCKTAKE','LOCATION_ITEM_BARCODE_STOCKTAKE','STOCKTAKECOUNT', '','False','False','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Session','Session',0, 'True','False','',1,'LOCATION_ITEM_BARCODE_STOCKTAKE','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Count','Count',1, 'True','True','',2,'LOCATION_ITEM_BARCODE_STOCKTAKE','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',2, 'True','True','',3,'LOCATION_ITEM_BARCODE_STOCKTAKE','PrescriptStockTakeCount_LOC_MILocation','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','MasterItem',3, 'True','False','',4,'LOCATION_ITEM_BARCODE_STOCKTAKE','PrescriptStockTakeCount_LOC_MITrackingEntity','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',4, 'True','False','',2,'LOCATION_ITEM_BARCODE_STOCKTAKE','','')