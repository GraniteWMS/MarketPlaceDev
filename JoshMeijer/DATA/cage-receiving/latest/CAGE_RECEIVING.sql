-- =============================================
-- Process Data Inserts
-- =============================================

-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate])
VALUES('True','CAGE_RECEIVING','CAGE_RECEIVING','RECEIVING','','False','False',NULL)

-- ProcessSteps
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Location','Receiving Location',0,'True','False','',1,'CAGE_RECEIVING','',NULL)

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Document','Document',1,'True','True','',2,'CAGE_RECEIVING','','978f45de-0367-4b8c-a5a5-68f4a9ff6012')

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('MasterItem','MasterItem',2,'True','True','',3,'CAGE_RECEIVING','','fbb42811-5297-4fd7-99e8-4b849725180b')

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Qty','Qty',3,'True','True','',4,'CAGE_RECEIVING','',NULL)

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('NoEntities','Number of TrackingEntities',4,'True','False','',2,'CAGE_RECEIVING','',NULL)

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Print','Print',99,'True','True','',0,'CAGE_RECEIVING','',NULL)

