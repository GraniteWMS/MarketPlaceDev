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
VALUES('Document','Document',1,'True','True','',2,'CAGE_RECEIVING','','88ddb149-b74b-4e1f-8a68-2565b3122df2')

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('MasterItem','MasterItem',2,'True','True','',3,'CAGE_RECEIVING','','5a5653c2-07dd-4013-90d5-e7b893c2cad5')

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Qty','Qty',3,'True','True','',4,'CAGE_RECEIVING','',NULL)

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('NoEntities','Number of TrackingEntities',4,'True','False','',2,'CAGE_RECEIVING','',NULL)

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Print','Print',99,'True','True','',0,'CAGE_RECEIVING','',NULL)

