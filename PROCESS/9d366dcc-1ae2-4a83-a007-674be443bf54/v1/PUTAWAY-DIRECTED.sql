-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-09 15:54:39
-- Source: PUTAWAY-DIRECTED
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','To Location',1, 'True','True','',0,'PUTAWAY-DIRECTED','','<div><medium>SUGGESTED LOCATIONS</medium></div>
{{"EXEC WebTemplate_Putaway_TrackingEntity @TrackingEntityBarcode= @TrackingEntity" |dbSelect({TrackingEntity})|basicTable({})}}
')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','Scan Tracking Barcode',0, 'True','True','',1,'PUTAWAY-DIRECTED','','{{ "SELECT *  FROM webtemplate_StockInReceiving " | dbSelect({}) | basicTable({selectOnColumn:"Barcode"}) }}')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','PUTAWAY-DIRECTED','PUTAWAY-DIRECTED','MOVE', '','False','False','')

-- =============================================
-- END OF SCRIPT
-- =============================================
