-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 07:32:33
-- Source: OUTSTANDING_LOCATION_COUNT
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',3, 'True','False','',4,'OUTSTANDING_LOCATION_COUNT','PrescriptStocktakeTrackingEntity','{{ "EXEC WebtemplateStockTakeTrackingEntity @Session = @Session, @Count = @Count, @Location = @Location" | dbSelect({Session, Count, Location}) | basicTable({enableSearch:false}) }}
')


-- ProcessStep_4
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('PalletConfirmation','PalletConfirmation',4, 'True','False','',5,'OUTSTANDING_LOCATION_COUNT','','')


-- ProcessStep_5
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',5, 'True','False','',2,'OUTSTANDING_LOCATION_COUNT','','')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',2, 'True','True','',3,'OUTSTANDING_LOCATION_COUNT','','{{ "EXEC WebtemplateStockTakeLocation @Session = @Session, @Count = @Count" | dbSelect({Session, Count}) | basicTable({enableSearch:true}) }}')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','OUTSTANDING_LOCATION_COUNT','OUTSTANDING_LOCATION_COUNT','STOCKTAKECOUNT', '','False','False','')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Session','Session',0, 'True','False','',1,'OUTSTANDING_LOCATION_COUNT','','')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Count','Count',1, 'True','True','',2,'OUTSTANDING_LOCATION_COUNT','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
