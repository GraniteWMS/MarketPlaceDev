-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-09 15:54:39
-- Source: ADHOC_STOCKTAKE
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',3, 'True','False','',4,'ADHOC_STOCKTAKE','PrescriptAdhocStockTake_TrackingEntity','')


-- ProcessStep_4
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('PalletConfirmation','PalletConfirmation',4, 'True','False','',5,'ADHOC_STOCKTAKE','','')


-- ProcessStep_5
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',5, 'True','False','',2,'ADHOC_STOCKTAKE','','')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',2, 'True','True','',3,'ADHOC_STOCKTAKE','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','ADHOC_STOCKTAKE','ADHOC_STOCKTAKE','STOCKTAKECOUNT', '','False','False','')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Session','Session',0, 'True','True','',1,'ADHOC_STOCKTAKE','PrescriptAdhocStockTake_Session','Select Existing session or enter new name to start new session

{{ "select Name from StockTakeSession WHERE Active = 1" | dbSelect({}) | basicList({submitOnClick:true}) }}

')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Count','Count',1, 'True','True','',2,'ADHOC_STOCKTAKE','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
