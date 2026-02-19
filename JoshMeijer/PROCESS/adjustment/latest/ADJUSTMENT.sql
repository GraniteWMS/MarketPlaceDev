-- =============================================
-- Process Data Inserts
-- =============================================

-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate])
VALUES('True','ADJUSTMENT','ADJUSTMENT','ADJUSTMENT','','False','False',NULL)

-- ProcessSteps
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Reference','Reference',0,'True','False','',1,'ADJUSTMENT','',NULL)

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('TrackingEntity','TrackingEntity',1,'True','True','',2,'ADJUSTMENT','PrescriptTest',NULL)

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Type','Type',2,'True','True','',3,'ADJUSTMENT','',NULL)

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Qty','Qty',3,'True','True','',4,'ADJUSTMENT','',NULL)

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Comment','Comment',4,'True','False','',5,'ADJUSTMENT','',NULL)

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Confirmation','Confirmation',5,'True','False','',1,'ADJUSTMENT','',NULL)

-- ProcessStepLookups
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep])
VALUES('CORRECT TO PHYSICAL','CORRECT TO PHYSICAL','ADJUSTMENT','Comment')

INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep])
VALUES('DAMAGED STOCK','DAMAGED STOCK','ADJUSTMENT','Comment')

INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep])
VALUES('EXPIRED STOCK','EXPIRED STOCK','ADJUSTMENT','Comment')

INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep])
VALUES('INCORRECT LABEL','INCORRECT LABEL','ADJUSTMENT','Comment')

INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep])
VALUES('PROCESS ERROR','PROCESS ERROR','ADJUSTMENT','Comment')

