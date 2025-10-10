-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 07:32:33
-- Source: SCRAP_WITH_REASON
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStepsLookup_0
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('Stolen','Stolen','SCRAP_WITH_REASON', 'Reference')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Comment','Details',1, 'True','False','',2,'SCRAP_WITH_REASON','Prescript_ScrapBarcode_Comment','')


-- ProcessStepsLookup_2
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('Other','Other','SCRAP_WITH_REASON', 'Reference')


-- ProcessStepsLookup_1
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('Damaged','Damaged','SCRAP_WITH_REASON', 'Reference')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Reference','Reason',0, 'True','False','',1,'SCRAP_WITH_REASON','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','SCRAP_WITH_REASON','SCRAP','SCRAP', '','True','False','')

-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Are You Sure?',3, 'True','False','',0,'SCRAP_WITH_REASON','','')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','Scan Barcode',2, 'True','True','',3,'SCRAP_WITH_REASON','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
