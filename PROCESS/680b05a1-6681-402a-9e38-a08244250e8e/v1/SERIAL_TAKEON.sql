-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 10:08:12
-- Source: SERIAL_TAKEON
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',3, 'True','True','',1,'SERIAL_TAKEON','PrescriptSerialTakeOnQty','')


-- ProcessStep_99
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Print','Print',99, 'True','True','',0,'SERIAL_TAKEON','','')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('SerialNumber','SerialNumber',2, 'True','False','',3,'SERIAL_TAKEON','PrescriptSerialTakeOnSerialNumber','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','SERIAL_TAKEON','SERIAL TAKEON','TAKEON', '','False','False','')

-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('MasterItem','MasterItem',1, 'True','True','',2,'SERIAL_TAKEON','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',0, 'True','False','',1,'SERIAL_TAKEON','','')


-- =============================================
-- END OF SCRIPT
-- =============================================
