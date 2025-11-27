-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 10:08:12
-- Source: STOCKTAKE_ADD_LOCATION
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',1, 'True','True','',2,'STOCKTAKE_ADD_LOCATION','PrescriptAddLocationsToStockTakeLocation','')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Confirm',2, 'True','True','',1,'STOCKTAKE_ADD_LOCATION','PrescriptAddLocationsToStockTakeConfirmation','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','STOCKTAKE_ADD_LOCATION','STOCKTAKE_ADD_LOCATION','CUSTOM', '','False','False','')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Session','Stocktake Session',0, 'True','True','',1,'STOCKTAKE_ADD_LOCATION','PrescriptAddLocationsToStockTake','<button onclick="ProceedNext(this.innerHTML)"  type="button">New Session</button>

{{ "SELECT Name FROM StockTakeSession WHERE Active = 1" | dbSelect({}) | basicTable({selectOnColumn:"Name", enableSearch:true}) }}')


-- =============================================
-- END OF SCRIPT
-- =============================================
