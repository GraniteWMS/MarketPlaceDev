-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 07:32:40
-- Source: LABELPRINT
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Barcode','Barcode',1, 'True','True','',1,'LABELPRINT','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Type','Type',0, 'True','True','',1,'LABELPRINT','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','LABELPRINT','LABELPRINT','LABELPRINT', '','False','False','')

-- =============================================
-- END OF SCRIPT
-- =============================================
