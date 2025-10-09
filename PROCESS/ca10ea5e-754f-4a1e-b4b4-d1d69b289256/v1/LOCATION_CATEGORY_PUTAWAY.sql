-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-09 15:54:39
-- Source: LOCATION_CATEGORY_PUTAWAY
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','To Location',0, 'True','True','',1,'LOCATION_CATEGORY_PUTAWAY','','')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',1, 'True','True','',1,'LOCATION_CATEGORY_PUTAWAY','PrescriptPutawayMatchCategoryTrackingEntity','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','LOCATION_CATEGORY_PUTAWAY','PUTAWAY','MOVE', '','False','False','')

-- =============================================
-- END OF SCRIPT
-- =============================================
