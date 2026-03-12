INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','LOCATION_ITEM_BARCODE_TAKEON','LOCATION_ITEM_BARCODE_TAKEON','TAKEON', '','False','False','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',0, 'True','True','',1,'LOCATION_ITEM_BARCODE_TAKEON','PrescriptTakeon_LOC_MILocation','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('MasterItem','MasterItem',1, 'True','True','',2,'LOCATION_ITEM_BARCODE_TAKEON','PrescriptTakeon_LOC_MIMasterItem','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('UseBarcode','UseBarcode',100, 'True','False','',0,'LOCATION_ITEM_BARCODE_TAKEON','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',2, 'True','True','',1,'LOCATION_ITEM_BARCODE_TAKEON','PrescriptTakeon_LOC_MIQty','')