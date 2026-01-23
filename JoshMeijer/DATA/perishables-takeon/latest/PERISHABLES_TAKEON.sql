-- =============================================
-- Process Data Inserts
-- =============================================

-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate])
VALUES('True','PERISHABLES_TAKEON','PERISHABLES_TAKEON','TAKEON','','False','False','')

-- ProcessSteps
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('MasterItem','MasterItem',1,'True','True','',2,'PERISHABLES_TAKEON','','')

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Location','Location',0,'True','False','',1,'PERISHABLES_TAKEON','','')

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Batch','Batch',2,'True','False','',3,'PERISHABLES_TAKEON','PrescriptPerishablesTakeonBatch','')

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('ExpiryDate','ExpiryDate (YYYYMMDD)',4,'True','False','',5,'PERISHABLES_TAKEON','PrescriptPerishablesTakeonExpiryDate','')

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Qty','Qty',5,'True','True','',6,'PERISHABLES_TAKEON','','')

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('NoEntities','Number of TrackingEntities',6,'True','False','',2,'PERISHABLES_TAKEON','','')

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Print','Print',99,'True','True','',0,'PERISHABLES_TAKEON','','')

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('ManufactureDate','ManufactureDate (YYYYMMDD)',3,'True','False','',4,'PERISHABLES_TAKEON','PrescriptPerishablesTakeonManufactureDate','')

