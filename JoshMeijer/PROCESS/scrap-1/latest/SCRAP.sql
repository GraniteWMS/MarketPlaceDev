-- =============================================
-- Process Data Inserts
-- =============================================

-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate])
VALUES('True','SCRAP','SCRAP','SCRAP','','False','False',NULL)

-- ProcessSteps
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Reference','Reference',0,'True','False','',1,'SCRAP','',NULL)

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('TrackingEntity','TrackingEntity',1,'True','True','',2,'SCRAP','',NULL)

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Comment','Select Scrap Reason',2,'True','False','',3,'SCRAP','',NULL)

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Confirmation','Continue with scrap transaction?',3,'True','False','',1,'SCRAP','',NULL)

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('IntegrationReference','IntegrationReference',0,'False','False','',0,'SCRAP','',NULL)

-- ProcessStepLookups
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep])
VALUES('MISSING STOCK','MISSING STOCK','SCRAP','Comment')

INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep])
VALUES('DAMAGED STOCK','DAMAGED STOCK','SCRAP','Comment')

INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep])
VALUES('EXPIRED STOCK','EXPIRED STOCK','SCRAP','Comment')

INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep])
VALUES('INCORRECT LABEL','INCORRECT LABEL','SCRAP','Comment')

INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep])
VALUES('PROCESS ERROR','PROCESS ERROR','SCRAP','Comment')

