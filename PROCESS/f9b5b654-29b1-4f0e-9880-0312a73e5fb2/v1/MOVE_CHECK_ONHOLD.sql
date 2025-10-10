-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 07:32:33
-- Source: MOVE_CHECK_ONHOLD
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','To Location',0, 'True','True','',1,'MOVE_CHECK_ONHOLD','','')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',1, 'True','True','',1,'MOVE_CHECK_ONHOLD','PrescriptMoveCheckOnHoldTrackingEntity','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','MOVE_CHECK_ONHOLD','MOVE','MOVE', '','False','False','')

-- =============================================
-- END OF SCRIPT
-- =============================================
