-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-09 15:54:39
-- Source: SIMPLE_FIFO_PICKING
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',2, 'True','True','',3,'SIMPLE_FIFO_PICKING','','')


-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',3, 'True','True','',2,'SIMPLE_FIFO_PICKING','','')


-- ProcessStep_200
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Step200','Step200',200, 'True','True','',0,'SIMPLE_FIFO_PICKING','PrescriptPickingStep200','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','SIMPLE_FIFO_PICKING','SIMPLE FIFO PICKING','PICKING', '','False','False','')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',0, 'True','True','',1,'SIMPLE_FIFO_PICKING','PrescriptPickingDocument','')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',1, 'True','True','',2,'SIMPLE_FIFO_PICKING','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
