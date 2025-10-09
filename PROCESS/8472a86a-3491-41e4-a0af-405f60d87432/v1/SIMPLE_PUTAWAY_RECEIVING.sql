-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-09 15:54:39
-- Source: SIMPLE_PUTAWAY_RECEIVING
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('MasterItem','MasterItem',1, 'True','True','',2,'SIMPLE_PUTAWAY_RECEIVING','PrescriptReceivingPutawayMasterItem','')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',2, 'True','True','',3,'SIMPLE_PUTAWAY_RECEIVING','PrescriptReceivingPutawayQty','')


-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('NoEntities','Number of TrackingEntities',3, 'True','False','',1,'SIMPLE_PUTAWAY_RECEIVING','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','SIMPLE_PUTAWAY_RECEIVING','SIMPLE_PUTAWAY_RECEIVING','RECEIVING', '','False','False','')

-- ProcessStep_100
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Receiving Location',100, 'True','False','',1,'SIMPLE_PUTAWAY_RECEIVING','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',0, 'True','True','',1,'SIMPLE_PUTAWAY_RECEIVING','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
