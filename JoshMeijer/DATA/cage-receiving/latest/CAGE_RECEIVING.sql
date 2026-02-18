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
VALUES('Document','Document',1,'True','True','',2,'CAGE_RECEIVING','','b3cbe73a-aae7-4956-b094-bbc25a51bcb3')

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('MasterItem','MasterItem',2,'True','True','',3,'CAGE_RECEIVING','','ab63af9d-dd9a-4a81-af6c-1f388d24abb2')

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Qty','Qty',3,'True','True','',4,'CAGE_RECEIVING','',NULL)

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('NoEntities','Number of TrackingEntities',4,'True','False','',2,'CAGE_RECEIVING','',NULL)

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Print','Print',99,'True','True','',0,'CAGE_RECEIVING','',NULL)

