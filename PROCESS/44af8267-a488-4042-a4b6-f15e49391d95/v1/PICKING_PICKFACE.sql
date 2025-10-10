-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 07:32:33
-- Source: PICKING_PICKFACE
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',2, 'True','True','',3,'PICKING_PICKFACE','','{{ "EXEC WebTemplate_PickingPickface_TrackingEntity @Document, @Location" | dbSelect({Document, Location}) | basicTable({selectOnColumn:"Barcode", enableSearch:true}) }}')


-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',3, 'True','True','',2,'PICKING_PICKFACE','','')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',1, 'True','True','',2,'PICKING_PICKFACE','PrescriptPickingPickfaceLocation','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','PICKING_PICKFACE','PICKING PICKFACE','PICKING', '','False','False','')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',0, 'True','True','',1,'PICKING_PICKFACE','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
