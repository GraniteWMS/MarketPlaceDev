-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 10:08:21
-- Source: STOCKTAKECOUNT
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',3, 'True','False','',4,'STOCKTAKECOUNT','','')


-- ProcessStep_4
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('PalletConfirmation','PalletConfirmation',4, 'True','False','',5,'STOCKTAKECOUNT','','')


-- ProcessStep_5
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',5, 'True','False','',2,'STOCKTAKECOUNT','','')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',2, 'True','True','',3,'STOCKTAKECOUNT','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','STOCKTAKECOUNT','STOCKTAKECOUNT','STOCKTAKECOUNT', '','False','False','')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Session','Session',0, 'True','False','',1,'STOCKTAKECOUNT','','')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Count','Count',1, 'True','True','',2,'STOCKTAKECOUNT','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
