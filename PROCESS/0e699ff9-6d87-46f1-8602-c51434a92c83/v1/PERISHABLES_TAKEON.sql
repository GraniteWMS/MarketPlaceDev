-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-09 15:54:39
-- Source: PERISHABLES_TAKEON
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_6
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('NoEntities','Number of TrackingEntities',6, 'True','False','',2,'PERISHABLES_TAKEON','','')


-- ProcessStep_5
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',5, 'True','True','',6,'PERISHABLES_TAKEON','','')


-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('ManufactureDate','ManufactureDate (YYYYMMDD)',3, 'True','False','',4,'PERISHABLES_TAKEON','PrescriptPerishablesTakeonManufactureDate','')


-- ProcessStep_99
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Print','Print',99, 'True','True','',0,'PERISHABLES_TAKEON','','')


-- ProcessStep_4
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('ExpiryDate','ExpiryDate (YYYYMMDD)',4, 'True','False','',5,'PERISHABLES_TAKEON','PrescriptPerishablesTakeonExpiryDate','')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('MasterItem','MasterItem',1, 'True','True','',2,'PERISHABLES_TAKEON','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','PERISHABLES_TAKEON','PERISHABLES TAKEON','TAKEON', '','False','False','')

-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Batch','Batch',2, 'True','False','',3,'PERISHABLES_TAKEON','PrescriptPerishablesTakeonBatch','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',0, 'True','False','',1,'PERISHABLES_TAKEON','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
