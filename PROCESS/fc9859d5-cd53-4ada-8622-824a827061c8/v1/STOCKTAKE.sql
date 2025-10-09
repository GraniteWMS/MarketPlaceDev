-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-09 15:54:53
-- Source: STOCKTAKE
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',3, 'True','False','',4,'STOCKTAKE','','')


-- ProcessStep_4
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('PalletConfirmation','PalletConfirmation',4, 'True','False','',5,'STOCKTAKE','','')


-- ProcessStep_5
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',5, 'True','False','',2,'STOCKTAKE','','')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',2, 'True','True','',3,'STOCKTAKE','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','STOCKTAKE','STOCKTAKE','STOCKTAKE', '','False','False','')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Session','Session',0, 'True','False','',1,'STOCKTAKE','','')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Count','Count',1, 'True','True','',2,'STOCKTAKE','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
