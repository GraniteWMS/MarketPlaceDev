INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','PUTAWAY-DIRECTED','PUTAWAY-DIRECTED','MOVE', '','False','False','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','Scan Tracking Barcode',0, 'True','True','',1,'PUTAWAY-DIRECTED','','{{ "SELECT *  FROM webtemplate_StockInReceiving " | dbSelect({}) | basicTable({selectOnColumn:"Barcode"}) }}')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','To Location',1, 'True','True','',0,'PUTAWAY-DIRECTED','','<div><medium>SUGGESTED LOCATIONS</medium></div>
{{"EXEC WebTemplate_Putaway_TrackingEntity @TrackingEntityBarcode= @TrackingEntity" |dbSelect({TrackingEntity})|basicTable({})}}
')